[ -n "$VIRTUALIZATION" ] && return 0

msg "Mounting all late filesystems..."
mount -a -L || emergency_shell
