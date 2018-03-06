[ -n "${JAILED}" ] && return 0

msg "Attaching encrypted disks..."
service geli onestart

msg "Initializing swap..."
swapon -aq || emergency_shell
