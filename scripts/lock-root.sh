#!/bin/sh -eux

echo "root:${PACKER_ROOT_HASH}" | chpasswd -e
