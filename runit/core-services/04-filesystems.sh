[ -n "$VIRTUALIZATION" ] && return 0

msg "Attaching encrypted disks..."
service geli onestart

msg "Initializing swap..."
swapon -aq || emergency_shell

msg "Checking filesystems..."
service fsck onestart

msg "Mounting / read-write..."
mount -uw / || emergency_shell

msg "Mounting all non-network filesystems..."
mount -a || emergency_shell

msg "Mounting ZFS file systems..."
zfs mount -a || emergency_shell
