#!/usr/bin/env bash

set -eux

# Packages
PACKAGES=(
  cloud-init
)

yum install -y ${PACKAGES[@]}

mkdir -p /etc/cloud
cat > /etc/cloud/cloud.cfg <<"EOF"
users:
  - default

disable_root: true
preserve_hostname: false


# The modules that run in the 'init' stage
cloud_init_modules:
  - migrator
  - bootcmd
  - write-files
  - resizefs
  - set_hostname
  - update_hostname
  - update_etc_hosts
  - ca-certs
  - rsyslog
  - users-groups
  - ssh


# The modules that run in the 'config' stage
cloud_config_modules:
# Emit the cloud config ready event
# this can be used by upstart jobs for 'start on cloud-config'.
  - emit_upstart
  - mounts
  - ssh-import-id
  - locale
  - set-passwords
  - grub-dpkg
  - apt-pipelining
  - apt-configure
  - package-update-upgrade-install
  - landscape
  - timezone
  - puppet
  - chef
  - salt-minion
  - mcollective
  - disable-ec2-metadata
  - runcmd
  - byobu


# The modules that run in the 'final' stage
cloud_final_modules:
  - rightscale_userdata
  - scripts-per-once
  - scripts-per-boot
  - scripts-per-instance
  - scripts-user
  - ssh-authkey-fingerprints
  - keys-to-console
  - phone-home
  - final-message
  - power-state-change


system_info:
  distro: debian
  default_user:
    name: admin
    lock_passwd: True
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: [sudo]
  paths:
    cloud_dir: /var/lib/cloud/
    templates_dir: /etc/cloud/templates/
    upstart_dir: /etc/init/
  package_mirrors:
    - arches: [default]
      failsafe:
        primary: http://ftp.debian.org/debian
EOF

CONSOLE="console=ttyS0,115200n8 console=tty0"
sed -i -e "s/\(GRUB_CMDLINE_LINUX.*\)\"/\1 $CONSOLE\"/" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

dracut --force --add-drivers xen_blkfront /boot/initramfs-$(uname -r).img

rm /etc/hosts
