[ -n "${JAILED}" ] && return 0

stop_boot() {
	msg_error "ABORTING BOOT"
	exit 1
}

if [ ! -r /etc/fstab ]; then
	msg_warn "No /etc/fstab: skipping disk checks."
else
	# During fsck ignore SIGQUIT
	trap : 3

	msg "Checking filesystems..."
	fsck -F -p

	err=$?
	if [ ${err} -eq 3 ]; then
		# TODO: msg_warn "Some of the devices might not be available; retrying"
		#root_hold_wait
		sleep 10
		msg "Restarting file system checks..."
		fsck -F -p
		err=$?
	fi

	case ${err} in
		0)
		;;
		2)
			stop_boot
			;;
		4)
			msg_warn "Rebooting..."
			# reboot
			# echo "Reboot failed; help!"
			# stop_boot
			exit 1
			;;
		8)
			msg_error "Automatic file system check failed; help!"
			stop_boot
			;;
		12)
			msg_error "Boot interrupted."
			stop_boot
			;;
		130)
			stop_boot
			;;
		*)
			msg_error "Unknown error ${err}; help!"
			stop_boot
			;;
	esac
fi
