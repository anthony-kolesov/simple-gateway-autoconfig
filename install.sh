#!/bin/bash

apt-get -y install ntp isc-dhcp-server bind9 openvpn

# Make backup copy of original DHCP configuration so it will be left as an example.
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.example

# DHCP server isn't started after installation.
start isc-dhcp-server

