# Prerequisites

This scripts and configurations are developed for Ubuntu server 12.04.

Before installations it is required to setup network cards and external network connection properly.

1. If you want to specify names to network devices than you can change them in `/etc/udev/rules.d/70-persistent-net.rules`. I don't know how to apply changes on the fly, so I can only suggest to reboot.

2. If external network requires static IP then setup it in /etc/network/interfaces. Then apply changes with:
```
sudo ifdown eth0
sudo ifup eth0
```

# Usage

Parameters are written in `variables.sh`. Modify it if required, you may want to use your custom DNS servers instead of default Google 8.8.8.8 and 8.8.4.4.

Run `./install.sh` first time to install required packages (bind9, isc-dhcp-server, ntp). Then run `./configure.sh` to create configuration files and restart applications to use it.

## DHCP

By default lease space start from X.X.X.100 and ends in X.X.X.199. Addresses are lease by default for one day, maximum for 7 days. Add fixed DHCP addresses to file `dhcpd.fixed.conf`, it will be included in `dhcpd.conf` as is.


