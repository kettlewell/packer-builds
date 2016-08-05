#!/usr/bin/env bash

set -eux

echo "==> SSH Config. No root login. No DNS. No GSSAPIAuthentication"

# echo '==> Disablng GSSAPI authentication to prevent timeout delay'
# echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

sed -i \
    -e '/^UseDNS/d' \
    -e '/^PermitRootLogin/d' \
    -e '/^GSSAPIAuthentication/d' \
    -e 's/^#UseDNS .*/UseDNS no/' \
    -e 's/^#PermitRootLogin .*/PermitRootLogin no/' \
    -e 's/^#GSSAPIAuthentication .*/GSSAPIAuthentication no/' \
    /etc/ssh/sshd_config
