[ -n "${JAILED}" ] && return 0
[ -x /sbin/devmatch ] || return 0

msg "Autoloading kernel modules"
for m in $(devmatch); do
	echo "${m}"
	kldload -n ${m}
done
