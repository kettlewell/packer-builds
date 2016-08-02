#!/usr/bin/env bash

set -eux

echo '==> Applying DNS Updates'

#  fix slow dns/ssh connections
#  http://www.linuxquestions.org/questions/showthread.php?p=4399340#post4399340
echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network

# add DNS nameservers
echo "DNS1=8.8.8.8" >> /etc/sysconfig/network
echo "DNS2=4.2.2.1" >> /etc/sysconfig/network
echo "DNS3=8.8.4.4" >> /etc/sysconfig/network

systemctl restart network
