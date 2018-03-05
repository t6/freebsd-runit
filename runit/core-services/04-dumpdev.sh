[ -n "${JAILED}" ] && return 0

msg "Enabling dump device..."

dumpdev=auto

dumpon_try()
{
	local flags

	if check_osver_major 12; then
		# On FreeBSD 12 encrypt dump and compress with ZSTD
		/sbin/dumpon -k /etc/dumppubkey -Z "${1}"
	else
		/sbin/dumpon "${1}"
	fi
	if [ $? -eq 0 ]; then
		# Make a symlink in devfs for savecore
		ln -fs "${1}" /dev/dumpdev
		return 0
	fi
	msg_warn "unable to specify $1 as a dump device"
	return 1
}

# Enable dumpdev so that savecore can see it. Enable it
# early so a crash early in the boot process can be caught.
#
dev=$(/bin/kenv -q dumpdev)
if [ -n "${dev}" ] ; then
	dumpon_try "${dev}"
	return $?
fi
while read dev mp type more ; do
	[ "${type}" = "swap" ] || continue
	[ -c "${dev}" ] || continue
	dumpon_try "${dev}" 2>/dev/null && return 0
done < /etc/fstab
msg_warn "No suitable dump device was found."
return 1
