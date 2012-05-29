#!/bin/bash

NAME=$1
DIR_PATH=$2
NETWORK=$3
COMMENT=$4

# Add Samba directory.
mkdir -p /srv/samba/$NAME/
ln -s $DIR_PAth /srv/samba/$NAME/

# Add Samba share.
echo "
[${NAME}]
comment = $COMMENT
path    = /srv/samba/$NAME
read only = no
guest only = yes
guest ok = yes
browsable = yes
" >> /etc/samba/smb.conf

# Add NFS directory
mkdir -p /srv/nfs/$NAME/

# Add fstab entry
echo "$DIR_PATH /srv/nfs/$NAME none bind 0 0" >> /etc/fstab
echo "/srv/nfs/$NAME $NETWORK(rw,nohide,insecure,no_subtree_check,async)" >> /etc/exports

# Remount and reload.
mount /srv/nfs/$NAME/
service nfs-kernel-server reload

