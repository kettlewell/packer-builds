#!/usr/bin/env bash 

set -eux

# This implementation of removing empty space seems cleaner to me
sudo dd if=/dev/zero of=/EMPTY bs=1M || :
sudo rm /EMPTY

# In CentOS 7, blkid returns duplicate devices
swap_device_uuid=`sudo /sbin/blkid -t TYPE=swap -o value -s UUID | uniq`
swap_device_label=`sudo /sbin/blkid -t TYPE=swap -o value -s LABEL | uniq`
if [ -n "$swap_device_uuid" ]; then
  swap_device=`readlink -f /dev/disk/by-uuid/"$swap_device_uuid"`
elif [ -n "$swap_device_label" ]; then
  swap_device=`readlink -f /dev/disk/by-label/"$swap_device_label"`
fi
sudo /sbin/swapoff "$swap_device"
sudo dd if=/dev/zero of="$swap_device" bs=1M || :
sudo /sbin/mkswap ${swap_device_label:+-L "$swap_device_label"} ${swap_device_uuid:+-U "$swap_device_uuid"} "$swap_device"






###################################################

# echo '==> Clear out swap and disable until reboot'
# set +e
# swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap)

# case "$?" in
#     2|0) ;;
#     *) echo "SWAP ERROR ... EXITING PREMATURELY"; exit 1 ;;
# esac

# set -e
# if [ "x${swapuuid}" != "x" ]; then
#     # Whiteout the swap partition to reduce box size
#     # Swap is disabled till reboot
#     swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid)
#     /sbin/swapoff "${swappart}"
#     dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed"
#     /sbin/mkswap -U "${swapuuid}" "${swappart}"
# fi

# dd if=/dev/zero of=/EMPTY bs=1M || echo "zero out /empty directory"
# rm -f /EMPTY

# Block until the empty file has been removed 
sleep 1
sync
sleep 1
sync
sleep 1
sync
