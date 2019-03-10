[ -n "${JAILED}" ] && return 0

echo "=> Initializing swap"
swapon -a
