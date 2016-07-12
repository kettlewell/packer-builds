#!/bin/sh

exit

set -eu

cat > /sbin/xvd_sd_symlink <<'EOF'
#!/bin/sh

if [ -z "${1:-}" ]; then
	echo "Usage: ${0##*/} <device>" >&2
	exit 1
fi

case ${1} in
	# This won't match if there are more than 999 partitions on a single
	# drive.
	xvd[a-z]|xvd[a-z][0-9]|xvd[a-z][0-9][0-9]|xvd[a-z][0-9][0-9][0-9])
		# This works but is a bashism so sed just to be on the safe side
		# even though we use a fork.
		# echo "${1/xvd/sd}"
		echo "${1}" | sed -e 's/xvd/sd/'
	;;
	*)
		echo "${1}"
	;;
esac
EOF

chmod 0755 /sbin/xvd_sd_symlink

echo 'KERNEL=="xvd*", PROGRAM="/sbin/xvd_sd_symlink %k", SYMLINK+="%c"' > /etc/udev/rules.d/50-xvd-sd-symlinks.rules
