[ -n "${JAILED}" ] && return 0
[ -d /usr/local/share/cpucontrol ] || return 0

echo "=> Updating CPU microcode"

kldload -n cpuctl || emergency_shell
for i in $(jot "$(sysctl -n hw.ncpu)" 0); do
	cpucontrol -u -d /usr/local/share/cpucontrol \
		"/dev/cpuctl${i}" 2>&1 |
		/usr/local/etc/runit/logger -p daemon.notice -t microcode_update ||
		(echo "ERROR: Microcode update failed" && emergency_shell)
done
if ! cpucontrol -e /dev/cpuctl0 >/dev/null 2>&1; then
	echo "ERROR: Re-evalulation of CPU flags failed"
	emergency_shell
fi
