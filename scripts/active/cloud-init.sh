#!/usr/bin/env bash 

set -eux

yum install -y cloud-init

# Setup ephemerals
#if [ ! -d /etc/cloud ]; then
#  mkdir -p /etc/cloud 
#fi

# mkdir -p /mnt/ephemeral0

#touch /etc/cloud/cloud.cfg

#cat >> /etc/cloud/cloud.cfg <<'EOF'
#datasource_list: [ Ec2, None ]
#EOF

# mounts:
#  - [ /dev/xvdb, /mnt/ephemeral0, ext4, "defaults,noatime,nodiratime,nofail", "0", "2" ]
# EOF


##Change cloud-init's default "centos" user to the more standard ec2-user
# sed -i \
#     -e 's/name: centos/name: ec2-user/' \
#     -e 's/gecos: .*/gecos: EC2 Default User/' \
#     /etc/cloud/cloud.cfg

systemctl enable cloud-config.service 
systemctl enable cloud-final.service
systemctl enable cloud-init-local.service
systemctl enable cloud-init.service
