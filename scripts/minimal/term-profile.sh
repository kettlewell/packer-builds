#!/usr/bin/env bash 

set -eux

touch /etc/profile.d/term-profile.sh
echo "export TERM=xterm" > /etc/profile.d/term-profile.sh
