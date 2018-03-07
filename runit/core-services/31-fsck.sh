[ -n "${JAILED}" ] && return 0

if [ ! -r /etc/fstab ]; then
	msg_warn "No /etc/fstab: skipping disk checks."
else
	msg "Checking filesystems..."
	fsck -F -p
	err=$?
	if [ ${err} -ne 0 ]; then
		msg_error "fsck exited with status ${err}"
		emergency_shell
	fi
fi
