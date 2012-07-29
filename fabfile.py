from fabric.api import *


# Configuration variables.
if 'bind_backup_file_path' not in env:
    env.bind_backup_file_path = '~/bind_config_backup.tar.bz2'

def dns_install():
    "Installs BIND9 DNS server to the system."
    sudo('apt-get install bind9')

def dns_backup():
    """Backup current Bind configuration files. Stores current BIND configuration
    to the home directory as a bind_config_backup.tar.bz2 archive. Filepaths in
    archive are relative."""
    run('tar -caf %(bind_backup_file_path)s --exclude=rndc.key /etc/bind/' % env)

def dns_restore():
    "Restores bind configuration created by `backup_bind_configuration."
    sudo('tar -xf %(bind_backup_file_path)s -C /' % env)

def dns_configure():
    "self hostname, self domain, admin email, self ip4 address, forwarding DNS srevers"
    pass

def dns_add_domain():
    "domain name, network prefix (reversed), network prefix"
    pass

def dns_add_entry():
    "domain, hostname, ipaddress"
    pass

def dns_remove_entry():
    "(domain + hostname) | ipaddress"
    pass

def dns_remove_domain():
    "Remove zone from DNS server configuration."
    pass    

def dns_reconfigure():
    "Reload configuration of DNS server."
    pass
