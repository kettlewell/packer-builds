#!/bin/sh -eux

mkdir -p /opt/git
cd /opt/git

git clone https://github.com/kettlewell/ansible-deploys.git

mkdir /etc/ansible
cd /etc/ansible

ln -s /opt/git/ansible-deploys/ansible.cfg ansible.cfg





