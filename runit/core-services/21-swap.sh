[ -n "${JAILED}" ] && return 0

msg "Initializing swap..."
swapon -aq || emergency_shell
