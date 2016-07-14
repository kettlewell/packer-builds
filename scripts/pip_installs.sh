#!/usr/bin/env bash 
set -eux

echo "Start PIP Install"
pip -q --no-cache-dir --disable-pip-version-check --log /var/log/pip_install.log install paramiko PyYAML Jinja2 httplib2 six

