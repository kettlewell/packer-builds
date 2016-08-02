#!/usr/bin/bash -eux

yum -y update

yum install -y tree  htop emacs-nox net-tools \
               bash-completion bash-completion-extras 

#               dracut-modules-growroot cloud-utils-growpart \
#               openssl-devel gcc patch  libffi-devel libffi
               
