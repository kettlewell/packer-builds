#!/usr/bin/env bash 

set -eux

echo "Yum Updating.... "
yum -y update

echo "Yum Cleaning... "
yum -y clean all

systemctl stop rsyslog
systemctl stop crond

find /var/log/ -type f | while read file; do cat /dev/null > "${file}";done


find /home/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;
find /root/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;

find /root/ -type f -exec rm -f {} \;

history -c

echo "shredding..."
echo "SHREDDING ON HOLD WHILE INVESTIGATING WHY IT CRASHES THINGS.... "
echo "Suspected of a bash glob issue... "
# shred -u /etc/ssh/*_key /etc/ssh/*_key.pub

# shred -u /root/.*history  /home/centos/.*history /home/*/.*history

echo "rm  /tmp/ "
rm -rf /tmp/*
echo "rm /etc/ssh/ssh_host_"
rm -f /etc/ssh/ssh_host_*

echo "zeroing out the bits..."
dd if=/dev/zero of=/zeros bs=1M || echo "dd exit code $? is suppressed"
rm -f /zeros

echo "syncing..."
sync
sync
sync

echo "End of cleanup"
echo ""
