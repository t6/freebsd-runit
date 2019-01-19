[ -n "${JAILED}" ] && return 0

echo "=> Mounting all late filesystems"
mount -a -L || emergency_shell
