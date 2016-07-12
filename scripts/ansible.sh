#!/usr/bin/env bash -eux

if [ ! -d /opt/git ]; then
  mkdir -p /opt/git
fi

cd /opt/git

git clone git://github.com/ansible/ansible.git --recursive

cd /opt/git/ansible

git reset --hard b599477242c44365236d4bae3e7766e37e6c4633

if [ ! -d /etc/ansible ]; then
  mkdir /etc/ansible
fi

cd /etc/ansible

ln -s /opt/git/ansible/contrib/inventory/ec2.ini ec2.ini
ln -s /opt/git/ansible/contrib/inventory/ec2.py  ec2.py

echo "127.0.0.1" > /etc/ansible/hosts

## source this in /etc/profile or similar
# source /opt/git/ansible/hacking/env-setup
# export ANSIBLE_INVENTORY=/etc/ansible/hosts
