[ -n "${JAILED}" ] && return 0
[ -r /etc/jail.conf ] || return 0

msg "Starting jails from /etc/jail.conf"
jail -f /etc/jail.conf -c -p1 &
