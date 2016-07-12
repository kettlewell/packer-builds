#!/usr/bin/env bash 

set -eux

mykern="$(uname -r | cut -d. -f1,2)"

mymaj="${mykern%.*}"
mymin="${mykern#*.}"

if [ "${mymaj}" -gt 3 ]; then
	exit 0
elif [ "${mymaj}" = 3 ]; then
	if [ "${mymin}" -gt 8 ]; then
		exit 0
	fi
fi

dracut -f
