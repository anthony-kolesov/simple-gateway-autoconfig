#!/bin/bash

# Devices
INTERNAL_DEV='eth0'

# External
# Place your contry/region poll address (us, europe, ru, etc).
NTP_POOL='ru.pool.ntp.org'

# Network
DOMAIN='prostor'
NETWORK_PREFIX='10.0.0'
NETWORK='10.0.0.0'
NETMASK='255.255.255.0'
SELF_ADDRESS_IP4="${NETWORK_PREFIX}.1"
DNS_1='8.8.8.8'
DNS_2='8.8.4.4'

# DHCP
DEFAULT_LEASE_TIME=86400
MAX_LEASE_TIME=604800
RANGE_START="${NETWORK_PREFIX}.100"
RANGE_END="${NETWORK_PREFIX}.199"

DHCP_CONF_FILE='/etc/dhcp/dhcpd.conf'

