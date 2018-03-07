[ -n "${JAILED}" ] && return 0

msg "Mounting / read-write..."
mount -uw / || emergency_shell

msg "Mounting all non-network filesystems..."
mount -a || emergency_shell

msg "Mounting ZFS file systems..."
zfs mount -va || emergency_shell
zfs share -a
if [ ! -r /etc/zfs/exports ]; then
	touch /etc/zfs/exports
fi
