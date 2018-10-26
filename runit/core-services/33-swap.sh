[ -n "${JAILED}" ] && return 0

msg "Initializing swap"
swapon -a || emergency_shell
