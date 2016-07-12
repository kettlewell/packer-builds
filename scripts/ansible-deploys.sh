#!/bin/sh -eux

if [ ! -d /opt/git ]; then
   mkdir -p /opt/git
fi

cd /opt/git

git clone https://github.com/kettlewell/ansible-deploys.git

if [ ! -d /etc/ansible ]; then
  mkdir -p /etc/ansible
fi

cd /etc/ansible

ln -s /opt/git/ansible-deploys/ansible.cfg ansible.cfg





