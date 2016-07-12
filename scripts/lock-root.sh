#!/usr/bin/env bash -eux

echo "root:${PACKER_ROOT_HASH}" | chpasswd -e
