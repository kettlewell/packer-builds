#!/usr/bin/env bash 

set -eux

if [ -f /boot/grub2/grub.cfg ]; then
    sed -i \
        -e 's/rhgb//g' \
        /etc/default/grub

    sed -i \
        -e 's/quiet//g' \
        /etc/default/grub

    grub2-mkconfig -o /boot/grub2/grub.cfg
fi
