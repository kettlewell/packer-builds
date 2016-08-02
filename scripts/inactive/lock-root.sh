#!/usr/bin/env bash 

set -eux

echo "root:${PACKER_ROOT_HASH}" | chpasswd -e
