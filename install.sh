#!/bin/bash

apt-get -y install ntp isc-dhcp-server bind9 openvpn samba nfs-kernel-server

# Make backup copy of original DHCP configuration so it will be left as an example.
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.example

# DHCP server isn't started after installation.
service isc-dhcp-server start

