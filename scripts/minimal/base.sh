#!/usr/bin/env bash

set -eux

echo "==> Base Config"

# SELINUX 
sed -i -e 's/^SELINUX=.*/SELINUX=permissive/' /etc/sysconfig/selinux


