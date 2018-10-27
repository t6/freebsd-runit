[ -n "${JAILED}" ] && return 0
dumpdev=$(kenv -q dumpdev)
[ -z "${dumpdev}" ] && return 0

msg "Enabling dump device"

# Encrypt dump if supported
if [ -r /etc/dumppubkey ] && kernel_has_feature ekcd; then
	dumpon -k /etc/dumppubkey "${dumpdev}"
else
	dumpon "${dumpdev}"
fi
if [ $? -neq 0 ]; then
	msg_warn "Unable to specify ${dumpdev} as a dump device"
	return 1
fi

# Make a symlink in devfs for savecore
ln -fs "${dumpdev}" /dev/dumpdev
