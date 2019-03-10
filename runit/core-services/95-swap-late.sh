[ -n "${JAILED}" ] && return 0

echo "=> Initializing late swap"
swapon -aL
