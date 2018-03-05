msg "Loading sysctl.conf(5)..."
[ -e /etc/sysctl.conf ] && sysctl -qf /etc/sysctl.conf > /dev/null
