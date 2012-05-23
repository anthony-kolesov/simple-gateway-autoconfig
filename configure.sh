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
# Use new configurations
#
invoke-rc.d ntp restart
reload isc-dhcp-server

