[ -n "${JAILED}" ] && return 0

echo "=> Initializing late swap"
swapon -aL || emergency_shell
