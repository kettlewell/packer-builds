#!/bin/sh

set -eu

# yum install -y ntp ntpdate
chkconfig ntpdate on
chkconfig ntpd on
