#!/usr/bin/env bash 

set -eux

# yum install -y cloud-init   

# put all the yum install files into one place for now... 

yum install -y git tree  htop emacs-nox bash-completion bash-completion-extras \
               dracut-modules-growroot cloud-utils-growpart \
               openssl-devel gcc patch net-tools libffi-devel libffi yum \
               python-pip python-devel python-wheel python-setuptools 
