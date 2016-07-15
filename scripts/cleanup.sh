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

echo "zeroing out the bits..."
dd if=/dev/zero of=/zeros bs=1M || echo "dd exit code $? is suppressed"
rm -f /zeros

echo "syncing..."
sync
sync
sync

echo "End of cleanup"
echo ""
