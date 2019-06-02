[ -n "${JAILED}" ] && return 0
[ -r /etc/jail.conf ] || return 0

echo "=> Starting jails from /etc/jail.conf"
jail -f /etc/jail.conf -c -p1 &
