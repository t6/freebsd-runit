[ -n "$VIRTUALIZATION" ] && return 0

msg "Mounting ZFS file systems..."
zfs mount -a || emergency_shell

msg "Mounting / read-write..."
mount -uw / || emergency_shell

msg "Mounting all non-network filesystems..."
mount -a || emergency_shell

msg "Starting automount daemons..."
/usr/sbin/automountd $(sysrc -qn automountd_flags) || emergency_shell
/usr/sbin/autounmountd $(sysrc -qn autounmountd_flags) || emergency_shell

msg "Enabling autofs..."
/usr/sbin/automount $(sysrc -qn automount_flags) || emergency_shell
