#!/bin/bash

source variables.sh

#
# NTP
#
sed -i -e "s/ubuntu.pool.ntp.org/${NTP_POOL}/" /etc/ntp.conf


#
# DHCP server
#

# Define interface to listen
sed -i -e "s/INTERFACES=\"\"/INTERFACES=\"${INTERNAL_DEV}\"/" /etc/default/isc-dhcp-server
# Backup current configuration
cp ${DHCP_CONF_FILE} ${DHCP_CONF_FILE}.configure_bak

# Generate dhcpd.conf file from template and client definitions.
sed -e "s/\${DOMAIN}/${DOMAIN}/
s/\${DEFAULT_LEASE_TIME}/${DEFAULT_LEASE_TIME}/
s/\${MAX_LEASE_TIME}/${MAX_LEASE_TIME}/
s/\${NETWORK}/${NETWORK}/
s/\${NETMASK}/${NETMASK}/
s/\${RANGE_START}/${RANGE_START}/
s/\${RANGE_END}/${RANGE_END}/
s/\${GATEWAY}/${SELF_ADDRESS_IP4}/
s/\${DNS_1}/${SELF_ADDRESS_IP4}/
s/\${DNS_2}/${DNS_1}/
s/\${DNS_3}/${DNS_2}/
" dhcpd.template.conf > dhcpd.conf

# If there is a file with fixed definitions then add it to generated configuration.
if [ -f dhcpd.fixed.conf ]; then
    cat dhcpd.fixed.conf >> dhcpd.conf
fi;

cp dhcpd.conf ${DHCP_CONF_FILE}


#
# DNS
#

# Enable forwarding of DNS records in /etc/bind/named.conf.options
# Remove current content (both commented and uncommetnted).
sed -i -r -e '/forwarders \{/,/\}/ { /([0-9]+\.){3}[0-9]+/ d }' /etc/bind/named.conf.options
# Uncomment lines if this is first run configuration.
sed -i -e '/\/\/ forwarders {/,/\/\/ };/ s/\/\/ //' /etc/bind/named.conf.options
# Insert custom DNS.
sed -i -e "/forwarders {/ a\
                ${DNS_1};\
                ${DNS_2};" /etc/bind/named.conf.options

# Setup local zones.
sed -e "s/\${DOMAIN}/${DOMAIN}/
s/\${NETWORK_PREFIX}/${NETWORK_PREFIX}/
s/\${NETWORK_PREFIX_REVERSE}/${NETWORK_PREFIX_REVERSE}/
" named.conf.local.template > named.conf.local
cp named.conf.local /etc/bind/

# Setup local forward zone.
sed -e "s/\${DOMAIN}/${DOMAIN}/
s/\${HOSTNAME}/${HOSTNAME}/
s/\${BIND_ADMIN}/${BIND_ADMIN}/
s/\${SELF_ADDRESS_IP4}/${SELF_ADDRESS_IP4}/
" dns_db.local.template > db.${DOMAIN}
cp db.${DOMAIN} /etc/bind/

# Setup local reverse zone.
sed -e "s/\${DOMAIN}/${DOMAIN}/
s/\${HOSTNAME}/${HOSTNAME}/
s/\${BIND_ADMIN}/${BIND_ADMIN}/
s/\${SELF_ADDRESS_IP4_VALUE}/${SELF_ADDRESS_IP4_VALUE}/
" dns_db.reverse.template > db.${NETWORK_PREFIX_REVERSE}
cp db.${NETWORK_PREFIX_REVERSE} /etc/bind/

# Proper resolv.conf references
# Remove any existing.
sed -r -i -e '/^$/,$ d' /etc/resolvconf/resolv.conf.d/head
echo "
nameserver 127.0.0.1
search ${DOMAIN}
" >> /etc/resolvconf/resolv.conf.d/head


#
# UFW
#

ufw allow ssh

# Enable routing.
sed -i -e 's/DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i -e 's/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/
s/#net\/ipv6\/conf\/default\/forwarding=1/net\/ipv6\/conf\/default\/forwarding=1/
s/#net\/ipv6\/conf\/all\/forwarding=1/net\/ipv6\/conf\/all\/forwarding=1/' /etc/ufw/sysctl.conf

# Remove current NAT rules
sed -i -e '/*nat/,/COMMIT/ d' /etc/ufw/before.rules
# Add NAT rules.
sed -i -e '/#   ufw-before-forward/ a\
*nat\
:POSTROUTING ACCEPT [0:0]\
-A POSTROUTING -s '${NETWORK}'/'${NETMASK_BITS}' -o '${EXTERNAL_DEV}' -j MASQUERADE\
-A POSTROUTING -s '${VPN_NETWORK}'/'${VPN_NETMASK_BITS}' -o '${INTERNAL_DEV}' -j MASQUERADE\
COMMIT' /etc/ufw/before.rules

# Allow DNS only for local network.
ufw allow from ${NETWORK}/${NETMASK_BITS} to any port 53


#
# OpenVPN
#
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz /etc/openvpn/
gzip -f -d /etc/openvpn/server.conf.gz

# Edit default configuration.
sed -i -e 's/proto udp/;proto udp/
s/;proto tcp/proto tcp/
s/;tls-auth/tls-auth/
/push 192.168.20/ a\
push "route '${NETWORK}' '${NETMASK}'"
' /etc/openvpn/server.conf
sed -i -e "" /etc/openvpn/server.conf


# Use new configurations
#
invoke-rc.d ntp restart
reload isc-dhcp-server
resolvconf -u
invoke-rc.d bind9 reload
ufw disable
ufw enable
invoke-rc.d openvpn restart

