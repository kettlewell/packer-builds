#!/usr/bin/env bash 

set -eux

echo "==> Network Config"

echo "==> Remove the traces of the template MAC address and UUIDs"
sed -i '/^\(HWADDR\|UUID\)=/d' /etc/sysconfig/network-scripts/ifcfg-e*

echo "==> Disable Network Manager"
systemctl stop NetworkManager
systemctl disable NetworkManager
