[ -n "$VIRTUALIZATION" ] && return 0

msg "Mounting ZFS file systems..."
zfs mount -a || emergency_shell

msg "Mounting / read-write..."
mount -uw / || emergency_shell

msg "Mounting all non-network filesystems..."
mount -a || emergency_shell
