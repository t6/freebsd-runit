[ -n "${JAILED}" ] && return 0
[ -x /sbin/devmatch ] || return 0

msg "Autoloading kernel modules"
for m in $(devmatch); do
	kldload -n "${m}"
done
