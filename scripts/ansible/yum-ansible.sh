#!/usr/bin/bash -eux

yum -y update

yum install -y git \
               python-pip \
               python-devel \
               python-wheel \
               python-setuptools 
               
#               dracut-modules-growroot cloud-utils-growpart \
#               openssl-devel gcc patch  libffi-devel libffi yum \
               
