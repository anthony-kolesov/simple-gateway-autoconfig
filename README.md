# Postrequisites

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

Add custom DNS records to files: `dns_db.local_records` for forward zone and to `dns_db.reverse_records` for reverse zone. They will be appended to the end of corresponding files as is.

## Sharing

NFS confguration taken from here: https://help.ubuntu.com/community/SettingUpNFSHowTo . Default configuration is very unrestrictive: guest can do anything. I'm not sure but it seems that directory that is shared must have 777 permission.

Add samba share to client: `apt-get install cifs-utils`. And for guest mount add to `/etc/fstab`:
```
//$SAMBA-SERVER-ADDRESS/$PATH $MOUNT-PATH cifs username=guest,password=,uid=1000 0 0
```

Add NFS share to client: `apt-get install nfs-common`. Add to `/etc/default/nfs-common`:
```
NEED_IDMAPD=yes
NEED_GSSD=no
```
Add to `/etc/fstab`:
```
$NFS-SERVER-ADDRESS:/$PATH  $MOUNT-PATH nfs4 _netdev,auto 0 0
```


# Add Public Share
To add public share to NFS and Samba run `add_public_share.sh` for each share. Run this script only after `configure.sh`. Added share will be available to write and read for anybody in the internal network. For network shares it is best to `source variables.sh` and then use variables `$NETWORK` and `$NETMASK`.
```
./add_public_share.sh $NAME $PATH                   $NETWORK/$NETMASK_BITS  $COMMENT
./add_public_share.sh share /mnt/data_disk/share/   10.0.0.0/24             "This is public files."
```

# DNS


## dns_install

Installs DNS server to the remote system. Default configuration of server is left unchanged. `apt-get` is used and of course `sudo` command will be used to install software.

## dns_backup and dns_restore

This command are used to backup and restore current BIND9 server configuration. By default configuration is stored in `~/dns_config_backup.tar.bz2`. This can be changed by specifying `dns_backup_file_path` variable to fab (via `--set` option). The same variable is used to restore configuration. Sudo is used to restore configuration, but for restore it isn't required.

## dns_configure

`dns_configure <ip-address-of-dns-server>*`: configure forwarding DNS servers. If BIND doesn't know answer for DNS request it will forwards request to the specified DNS server. Probably that must be the DNS server provided by your ISP (it will provide the lest latency). Google DNS servers also can be used: 8.8.8.8 and 8.8.4.4.

## dns_reload

Reload current BIND9 configuration. It is required to run this action after configuration has been changed so server will use new configuration. Runs as a root and uses `service` tool.

## Example sequence of actions:

```
fab dns_install
fab dns_backup
fab dns_configure:8.8.8.8,8.8.4.4
fab dns_add_domain
fab dns_add_entry
fab dns_reload
```
