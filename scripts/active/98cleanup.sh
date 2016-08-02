#!/usr/bin/bash -eux

#
# clean up any packages
#
# yum -y erase

#
# clean caches
#
yum -y clean all

sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux

# fix network names
# yum -y install grub2-tools
# sed -i -e 's/quiet/quiet net.ifnames=0 biosdevname=0/' /etc/default/grub
# grub2-mkconfig -o /boot/grub2/grub.cfg

echo "==> Remove the traces of the template MAC address and UUIDs"
sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-e*

#sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
#sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*


sed -i 's/^.*UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

systemctl stop NetworkManager
systemctl disable NetworkManager
