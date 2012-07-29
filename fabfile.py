from fabric.api import *
from fabric.contrib.files import sed


# Configuration variables.
if 'dns_backup_file_path' not in env:
    env.dns_backup_file_path = '~/dns_config_backup.tar.bz2'
if 'dns_options_file_path' not in env:
    env.dns_options_file_path = '/etc/bind/named.conf.options'

def dns_install():
    "Installs BIND9 DNS server to the system."
    sudo('apt-get install bind9')

def dns_backup():
    """Backup current Bind configuration files. Stores current BIND configuration
    to the home directory as a bind_config_backup.tar.bz2 archive. Filepaths in
    archive are relative."""
    run('tar -caf %(dns_backup_file_path)s --exclude=rndc.key /etc/bind/' % env)

def dns_restore():
    "Restores bind configuration created by `backup_bind_configuration."
    sudo('tar -xf %(dns_backup_file_path)s -C /' % env)

def dns_configure(*args):
    "self hostname, self domain, admin email, self ip4 address, forwarding DNS srevers"
    print(args)
    print(env.dns_options_file_path)
    # Can't use fabric sed command because it doesn't support delete action.
    # Remove current content (both commented and uncommetnted).
    #sudo("sed -i.bak -r -e '/forwarders \{/,/\}/ { /([0-9]+\.){3}[0-9]+/ d }' /etc/bind/named.conf.options")
    local("sed -i.bak -r -e '/forwarders \{/,/\}/ { /([0-9]+\.){3}[0-9]+/ d }' %(dns_options_file_path)s" % env)
    # Uncomment lines if this is first run configuration.
    local("sed -i -e '/\/\/ forwarders {/,/\/\/ };/ s/\/\/ //' %(dns_options_file_path)s" % env)
    # Insert custom DNS.
    dns_servers = list(args)
    dns_servers.reverse() # Appending results in reversed order, so need to neutralize it.
    for forward_dns in dns_servers:
        local("""sed -i -e '/forwarders {/ a\
                \t%s;' %s""" % (forward_dns, env.dns_options_file_path))

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
