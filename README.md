# Prerequisites

This scripts and configurations are developed for Ubuntu server 12.04.

Before installations it is required to setup network cards and external network connection properly.

1. If you want to specify names to network devices than you can change them in `/etc/udev/rules.d/70-persistent-net.rules`. There MAC addresses are linked to device names. I don't know how to apply changes on the fly, so I can only suggest to reboot

2. If external network requires static IP then setup it in /etc/network/interfaces. Then apply changes with:
```
sudo ifdown eth0
sudo ifup eth0
```

