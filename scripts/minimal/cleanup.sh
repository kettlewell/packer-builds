#!/usr/bin/env bash 

set -eux

echo "==> Base Config"

# NB: Should randomize, or just disable
# echo "==> Lock Root Account"
# echo "root:${PACKER_ROOT_HASH}" | chpasswd -e

echo "==> Yum Updating.... "
yum -y update

#
# clean caches
#
yum -y clean all

echo "==> Stopping Uncessarry Services"
# systemctl disable avahi-daemon.service
# systemctl disable kdump.service
# systemctl stop rsyslog
# systemctl stop crond


# sanitize log files
find /var/log -type f | while read f; do echo -ne '' > $f; done;
find /home/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;
find /root/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;
find /root/ -type f -exec rm -f {} \;

# Clear wtmp
cat /dev/null > /var/log/wtmp

# remove files under tmp directory
rm -rf /tmp/*

# Clear core files
rm -f /core*

# Clean network
rm -f /etc/udev/rules.d/70-persistent-net.rules

# clear out machine id
rm -f /etc/machine-id

# Remove Virtualbox specific files
rm -rf /usr/src/vboxguest* /usr/src/virtualbox-ose-guest*
rm -rf *.iso *.iso.? /tmp/vbox /{root,vagrant}/.vbox_version

# Rebuild RPM DB
rpmdb --rebuilddb
rm -f /var/lib/rpm/__db*




# clean history
history -c
