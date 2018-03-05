[ -n "$VIRTUALIZATION" ] && return 0

msg "Enabling dump device..."

dumpdev=$(sysrc -qn dumpdev)
dumppubkey=$(sysrc -qn dumppubkey)

dumpon_try()
{
	local flags

	flags=$(sysrc -qn dumpon_flags)
	if [ -n "${dumppubkey}" ]; then
		warn "The dumppubkey variable is deprecated.  Use dumpon_flags."
		flags="${flags} -k ${dumppubkey}"
	fi
	/sbin/dumpon ${flags} "${1}"
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
case ${dumpdev} in
[Nn][Oo] | '')
	;;
[Aa][Uu][Tt][Oo])
	dev=$(/bin/kenv -q dumpdev)
	if [ -n "${dev}" ] ; then
		dumpon_try "${dev}"
		return $?
	fi
	while read dev mp type more ; do
		[ "${type}" = "swap" ] || continue
		[ -c "${dev}" ] || continue
		dumpon_try "${dev}" 2>/dev/null && return 0
	done </etc/fstab
	echo "No suitable dump device was found." 1>&2
	return 1
	;;
*)
	dumpon_try "${dumpdev}"
	;;
esac
