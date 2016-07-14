#!/usr/bin/env bash 
set -eux

echo "Pip List BEFORE Install"
pip list

echo "Start PIP Install"
pip -vvv --no-cache-dir --disabe-pip-version-check --log /var/log/pip_install.log install paramiko PyYAML Jinja2 httplib2 six

echo "Pip List AFTER Install"
pip list

