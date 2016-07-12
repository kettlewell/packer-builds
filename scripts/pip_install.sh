#!/usr/bin/env bash 
set -eux

echo "Start PIP Install"
pip install paramiko PyYAML Jinja2 httplib2 six
