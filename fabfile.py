from fabric.api import *


# Configuration variables.
env.bind_backup_file_path = '~/bind_config_backup.tar.bz2'


def backup_bind_configuration():
    """Backup current Bind configuration files. Stores current BIND configuration
    to the home directory as a bind_config_backup.tar.bz2 archive. Filepaths in
    archive are relative."""
    run('tar -caf %(bind_backup_file_path)s --exclude=rndc.key /etc/bind/' % env)

def restore_bind_configuration():
    "Restores bind configuration created by `backup_bind_configuration."
    sudo('tar -xf %(bind_backup_file_path)s -C /' % env)

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

