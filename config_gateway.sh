#!/bin/bash

# 1.   Ensure interface names are setup correctly in /etc/udev/rules.d/70-persistent-net.rules
# 2.   Network interfaces setup in /etc/network/interfaces.
# 3. - ethtool package to control ethernet cards - optional.
# 4. - Setup dns-nameservers & dns-search in interfaces file.

# Run this script as root.

# Sample network configuration
# auto eth1
# iface eth1 inet dhcp
#
# auto eth0
# iface eth0 inet static
# address 10.0.0.1
# netmask 255.255.255.0


# Network devices
EXTERNAL_DEV='eth1'
INTERNAL_DEV='eth0'

# Local network configuration
HOSTNAME='gateway'
DOMAIN='prostor'
NETWORK='10.0.0.0'
DNS_REVERSE_NETWORK='0.0.10'
DNS_DB_FILE_NETWORK='10'
SELF_IP='1'
NETMASK='255.255.255.0'
DHCP_RANGE_START='10.0.0.100'
DHCP_RANGE_END='10.0.0.199'
DHCP_LEASE_TIME='86400'
DHCP_MAX_LEASE_TIME='364800'
SELF_ADDRESS='10.0.0.1'
GATEWAY=$SELF_ADDRESS
DNS_1='8.8.8.8'
DNS_2='8.8.4.4'
BIND_ADMIN='kolesov.3253838.ru'

# Additional configuration
DHCP_CONF_FILE='/etc/dhcp/dhcpd.conf'


#
# NTP
#
apt-get -y install ntp
# Use russian NTP servers instead of Ubuntus.
sed -i -e "s/ubuntu.pool.ntp.org/ru.pool.ntp.org/" /etc/ntp.conf


#
# DHCP server
#
apt-get -y install isc-dhcp-server
# Define interface to listen
sed -i -e "s/INTERFACES=\"\"/INTERFACES=\"${INTERNAL_DEV}\"/" /etc/default/isc-dhcp-server
# Backup current configuration
cp $DHCP_CONF_FILE ${DHCP_CONF_FILE}.bak

# Change domain.
sed -i -e "s/example.org/${DOMAIN}/g" $DHCP_CONF_FILE
# Make this DHCP server authoritative in this network.
sed -i -e "s/#authoritative;/authoritative;/" $DHCP_CONF_FILE

# Set lease times
sed -i -e "s/default-lease-time.*$/default-lease-time $DHCP_LEASE_TIME" $DHCP_CONF_FILE
sed -i -e "s/max-lease-time.*$/max-lease-time $DHCP_MAX_LEASE_TIME" $DHCP_CONF_FILE

# Configure local network.
echo "subnet $NETWORK $NETMASK {
    range $DHCP_RANGE_START $DHCP_RANGE_END;
    option routers $GATEWAY;
    option domain-name-servers $SELF_ADDRESS, $DNS_1, $DNS_2;
    option domain-name "$DOMAIN";
}

# Define fixed IP addresses here.
#host $<HOST_NAME> {
#   hardware ethernet $<MAC_ADDRESS_COMMA_DELIMITED>;
#   fixed-address $<IP_OR_DNS_NAME>;
#}
" >> $DHCP_CONF_FILE

# Use new configuration
reload isc-dhcp-server


#
# DNS
#
apt-get -y install bind9

# Enable forwarding of DNS records in /etc/bind/named.conf.options
sed -i -e '/\/\/ forwarders {/,/\/\/ };/ \\/\/ //' /etc/bind/named.conf.options
sed -i -e '/0\.0\.0\.0/ d' /etc/bind/named.options
sed -i -e '/forwarders {/ a\
                84.52.107.107;\
                8.8.8.8;\
                8.8.4.4;' /etc/bind/named.conf.options

# Setup zones in /etc/bind/named.conf.local
echo '# Main zone
zone "${DOMAIN}" {
    type master;
    file "/etc/bind/db.${DOMAIN}";
};

zone "${DNS_REVERSE_NETWORK}.in-addr.arpa" {
    type master;
    notify no;
    file "/etc/bind/db.${DNS_DB_FILE_NETWORK}";
};' >>> /etc/bind/named.conf.local


# Setup main zone zone.
echo '$TTL  604800
@   IN  SOA ${HOSTNAME}.${DOMAIN}. ${BIND_ADMIN}. (
    201205171   ; Serial
       604800   ; Refresh
        86400   ; Retry
      2419200   ; Expire
       604800 ) ; Negative Cache TTL
;
@               IN  NS      ${HOSTNAME}.${DOMAIN}.
@               IN  A       ${SELF_ADDRESS}
@               IN  AAAA    ::1
${HOSTNAME}     IN  A       ${SELF_ADDRESS}
ntp             IN  A       ${SELF_ADDRESS}
fs              IN  A       ${SELF_ADDRESS}
' > /etc/bind/db.${DOMAIN}

# Setup reverse zone.
echo '$TTL  604800
@   IN  SOA ${HOSTNAME}.${DOMAIN}. ${BIND_ADMIN}. (
    201205171   ; Serial
       604800   ; Refresh
        86400   ; Retry
      2419200   ; Expire
       604800 ) ; Negative Cache TTL
;
@               IN  NS      ${HOSTNAME}.${DOMAIN}.
@               IN  A       ${SELF_ADDRESS}
@               IN  AAAA    ::1
${SELF_IP}      IN  A       ${HOSTNAME}.${DOMAIN}.
' > /etc/bind/db.${DNS_DB_FILE_NETWORK}

# Allow forwarding with UFW
ufw allow ssh
ufw enable
sed -i -e 's/DEFAULT_FORWARD_POLICY=.*/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
sed -i -e "s/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/" /etc/ufw/sysctl.conf
sed -i -e "s/#net\/ipv6\/conf\/default\/forwarding=1/net\/ipv6\/conf\/default\/forwarding=1/" /etc/ufw/sysctl.conf
sed -i -e "s/#net\/ipv6\/conf\/all\/forwarding=1/net\/ipv6\/conf\/all\/forwarding=1/" /etc/ufw/sysctl.conf
# Add this to /etc/ufw/before.rules
# *nat
# :POSTROUTING ACCEPT [0:0]
# # Forward traffic from eth1 through eth0.
# -A POSTROUTING -s 192.168.0.0/24 -o eth0 -j MASQUERADE
# COMMIT

# Allow DNS only for local network.
ufw allow from 192.168.3.0/24 to any port 53

