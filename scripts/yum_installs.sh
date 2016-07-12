#!/usr/bin/env bash -eux

# put all the yum install files into one place for now... 

# If I decide to later build more than just the ansible master from this,
# I can create a base_yum_install, ansible_yum_install, other_yum_install, etc
#
#  For now... this is fine, and better than maintaining the granularity I was
#  attempting previously.
#

yum install -y git openssl-devel python-devel gcc tree yum python-pip python-wheel python-setuptools patch net-tools libffi-devel libffi htop emacs-nox dracut-modules-growroot cloud-init cloud-utils-growpart
