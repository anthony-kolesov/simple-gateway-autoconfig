#!/bin/bash

apt-get -y install ntp isc-dhcp-server bind9

# DHCP server isn't started after installation.
start isc-dhcp-server

