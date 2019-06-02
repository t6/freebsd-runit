[ -n "${JAILED}" ] && return 0

if [ ! -r /etc/fstab ]; then
	echo "WARNING: No /etc/fstab: skipping disk checks."
else
	echo "=> Checking filesystems"
	fsck -F -p
	err=$?
	if [ ${err} -ne 0 ]; then
		echo "ERROR: fsck exited with status ${err}"
		emergency_shell
	fi
fi
