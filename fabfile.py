from fabric.api import *


def backup_bind_configuration():
    "Backup current Bind configuration files."
    run('tar -caPf ~/bind_config_backup.tar.bz2 --exclude=rndc.key /etc/bind/')

def configure_bind():
    "self hostname, self domain, admin email, self ip4 address"
    pass

def add_domain():
    "domain name, network prefix (reversed), network prefix"
    pass

def add_dns_entry():
    "domain, hostname, ipaddress"
    pass

def remove_dns_entry():
    "(domain + hostname) | ipaddress"
    pass

