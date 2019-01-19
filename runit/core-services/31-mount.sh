[ -n "${JAILED}" ] && return 0

echo "=> Mounting / read-write"
mount -uw / || emergency_shell

echo "=> Mounting all non-network filesystems"
mount -a || emergency_shell
