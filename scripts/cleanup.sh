#!/usr/bin/env bash -eux

echo "Yum Updating.... "
yum -y update
echo "Yum Cleaning... "
yum -y clean all

systemctl stop rsyslog
systemctl stop crond
#service rsyslog stop
#service crond stop

rm -f /etc/ssh/ssh_host_*

find /var/log/ -type f | while read file; do cat /dev/null > "${file}";done

rm -f /tmp/*

find /home/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;
find /root/ -mindepth 1 -maxdepth 1 -type d -exec rm -fr {} \;
find /root/ -type f -exec rm -f {} \;
history -c

shred -u /etc/ssh/*_key /etc/ssh/*_key.pub
shred -u /root/.*history  /home/centos/.*history /home/*/.*history
dd if=/dev/zero of=/zeros bs=1M
rm -f /zeros

sync
sync
sync
