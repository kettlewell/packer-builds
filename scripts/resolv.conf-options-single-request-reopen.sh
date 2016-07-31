#!/usr/bin/env bash

set -eux

echo 'RES_OPTIONS="${RES_OPTIONS} single-request-reopen"' >> /etc/sysconfig/network
