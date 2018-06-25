if [ -z "${JAILED}" ]; then
	msg "Mounting / read-write"
	mount -uw / || emergency_shell

	msg "Mounting all non-network filesystems"
	mount -a || emergency_shell

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
