#!/usr/bin/env bash 

set -eux

if [ -f /boot/grub2/grub.cfg ]; then
    sed -i \
        -e 's/rhgb//g' \
        /etc/default/grub

    sed -i \
        -e 's/quiet//g' \
        /etc/default/grub

    CONSOLE="console=ttyS0,115200n8 console=tty0"

    MEMORY_LIMIT="cgroup_enabled=memory"
    SWAP_COUNT="swapaccount=1"
    # Enabling memory limit & control of swap
    # sed -i '/kernel \/vmlinuz-3.14/ s/$/ cgroup_enabled=memory swapaccount=1/' /boot/grub/grub.conf

    sed -i \
        -e "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 $CONSOLE $MEMORY_LIMIT $SWAP_COUNT\"/"  \
        /etc/default/grub

    grub2-mkconfig -o /boot/grub2/grub.cfg

    # dracut --force --add-drivers xen_blkfront /boot/initramfs-$(uname -r).img

    rpm -qa kernel | sed 's/^kernel-//'  | xargs -I {} dracut  --force --add-drivers xen_blkfront /boot/initramfs-{}.img {}

    rm /etc/hosts
fi


