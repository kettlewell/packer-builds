#!/usr/bin/bash -eux

#
# clean up any packages
#
yum -y erase

#
# clean caches
#
yum -y clean all

sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux

echo "==> Remove the traces of the template MAC address and UUIDs"
sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-e*

echo "==> Don't use DNS with SSH"
sed -i 's/^.*UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

echo "==> Disable Network Manager"
systemctl stop NetworkManager
systemctl disable NetworkManager
