#!/usr/bin/bash -ux

dd if=/dev/zero of=/EMPTY bs=1M || echo "zero out /empty directory"
rm -f /EMPTY

# Block until the empty file has been removed 
sleep 2
sync
sleep 2
sync
sleep 2
sync
