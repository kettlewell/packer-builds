#!/bin/sh

set -eu

# Set systemd to not use "predictable network interface names"
# http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

if [ -f /etc/default/grub ]; then
    sed -i \
        -e '/GRUB_CMDLINE_LINUX/s/"$/ net.ifnames=0 biosdevname=0"/g' \
        /etc/default/grub

    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

if [ -f /boot/grub/grub.conf ]; then
    sed -i \
        -e '/kernel /s/$/ net.ifnames=0 biosdevname=0/g' \
        /boot/grub/grub.conf
fi

udev_files='
    /etc/udev/rules.d/70-persistent-net.rules
    /etc/udev/rules.d/80-net-name-slot.rules
    /etc/udev/rules.d/80-net-setup-link.rules
'

for f in ${udev_files}; do
    if [ -f "${f}" ]; then
        rm -f "${f}"
    fi

    ln -s /dev/null "${f}"
done

# systemd still creates the predictable NIC ifcfg file which we don't want

ifcfg_path=/etc/sysconfig/network-scripts
ifcfg_to_save='eth0 lo'
ifcfg_tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/${0##*/}.XXXXXX")"

for i in ${ifcfg_to_save}; do
    if [ -f "${ifcfg_path}/ifcfg-${i}" ]; then
        mv "${ifcfg_path}/ifcfg-${i}" "${ifcfg_tmpdir}/${i}"
    fi
done

rm -f "${ifcfg_path}"/ifcfg-*

for i in ${ifcfg_to_save}; do
    if [ -f "${ifcfg_tmpdir}/${i}" ]; then
        mv "${ifcfg_tmpdir}/${i}" "${ifcfg_path}/ifcfg-${i}"
    fi
done

rm -fr "${ifcfg_tmpdir}"

# MAC/UUID is specific to the cloning environment, not the target

if [ -f "${ifcfg_path}/ifcfg-eth0" ]; then
    sed -i \
        -e '/^HWADDR/d' \
        -e '/^UUID/d' \
        "${ifcfg_path}/ifcfg-eth0"
else
    cat > "${ifcfg_path}/ifcfg-eth0" <<-'EOF'
        BOOTPROTO=dhcp
        DEVICE=eth0
        IPV6INIT=yes
        NM_CONTROLLED=yes
        ONBOOT=yes
        TYPE=Ethernet
EOF
fi

if [ ! -f /etc/sysconfig/network ]; then
    echo 'NETWORKING=yes' > /etc/sysconfig/network
fi

if ! grep -q '^NETWORKING=' /etc/sysconfig/network; then
    echo 'NETWORKING=yes' >> /etc/sysconfig/network
fi
