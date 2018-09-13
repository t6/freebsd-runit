# No ZFS support on FreeBSD/powerpc
check_arch powerpc || return 0

if [ -z "${JAILED}" ]; then
	msg "Mounting ZFS file systems"
	zfs mount -va || emergency_shell

	msg "Sharing ZFS file systems"	
	zfs share -a || emergency_shell
	if [ ! -r /etc/zfs/exports ]; then
		touch /etc/zfs/exports
	fi
elif [ $(sysctl -n security.jail.mount_zfs_allowed) -eq 1 ]; then
	msg "Mounting ZFS file systems"
	zfs mount -a || emergency_shell
fi
