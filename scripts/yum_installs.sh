#!/usr/bin/env bash 

set -eux

# yum install -y cloud-init   

# put all the yum install files into one place for now... 

# If I decide to later build more than just the ansible master from this,
# I can create a base_yum_install, ansible_yum_install, other_yum_install, etc
#
#  For now... this is fine, and better than maintaining the granularity I was
#  attempting previously.
#

# yum install -y git tree  htop emacs-nox bash-completion bash-completion-extras

# yum install -y dracut-modules-growroot cloud-utils-growpart 

# yum install -y openssl-devel gcc patch net-tools libffi-devel libffi yum

# yum install -y python-pip python-devel python-wheel python-setuptools 

# yum install -y 
