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

Run `./install.sh` first time to install required packages (bind9, isc-dhcp-server, ntp). Then run ./generate_certs.sh for VPN certificates. Then run `./configure.sh` to create configuration files and restart applications to use it.

## DHCP

By default lease space start from X.X.X.100 and ends in X.X.X.199. Addresses are lease by default for one day, maximum for 7 days. Add fixed DHCP addresses to file `dhcpd.fixed.conf`, it will be included in `dhcpd.conf` as is.

## DNS

Add custom DNS records to files: `dns_db.local_reverse` for forward zone and to `dns_db.reverse_records` for reverse zone. They will be appended to the end of corresponding files as is.

## Samba

Default configuration is very unrestrictive: guest can do anything. Add shares descriptions to file `smb.shares.conf`, it will be appended tp `smb.conf`. 

Example configuration of share that is fully accessible to anyone:
```[share]
comment     = Public files
path        = /srv/smb/share
read only   = no
guest only  = yes
guest ok    = yes
browsable   = yes
```

