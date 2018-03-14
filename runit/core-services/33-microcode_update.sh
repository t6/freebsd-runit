[ -n "${JAILED}" ] && return 0
[ -d /usr/local/share/cpucontrol ] || return 0

msg "Updating CPU microcode..."

if ! kldstat -q -m cpuctl; then
	if ! kldload cpuctl > /dev/null 2>&1; then
		msg_error "Can't load cpuctl module"
		emergency_shell
	fi
fi

for i in $(jot $(sysctl -n hw.ncpu) 0); do
	cpucontrol -u -d /usr/local/share/cpucontrol \
		/dev/cpuctl${i} 2>&1 \
		| logger -p daemon.notice -t microcode_update || \
		(msg_error "Microcode update failed" && emergency_shell)
done
cpucontrol -e /dev/cpuctl0 >/dev/null 2>&1
if [ $? -ne 0 ]; then
	msg_error "Re-evalulation of CPU flags failed"
	emergency_shell
fi
