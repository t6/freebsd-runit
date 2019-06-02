[ -n "${JAILED}" ] && return 0
dumpdev=$(kenv -q dumpdev)
[ -z "${dumpdev}" ] && return 0

echo "=> Enabling dump device"

# Encrypt dump if supported
if [ -r /etc/dumppubkey ] && [ "$(sysctl -qn "kern.features.ekcd")" = "1" ]; then
	dumpon -k /etc/dumppubkey "${dumpdev}"
else
	dumpon "${dumpdev}"
fi
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
	echo "WARNING: Unable to specify ${dumpdev} as a dump device"
	return 1
fi

# Make a symlink in devfs for savecore
ln -fs "${dumpdev}" /dev/dumpdev
