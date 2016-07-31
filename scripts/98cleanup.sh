set -ux

#
# clean up any packages
#
# yum -y erase

#
# clean caches
#
yum -y clean all

#sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
#sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*

#cd /etc 
#> ./resolv.conf

#sed -i 's/^.*UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
