if [ -e "/etc/pf.conf" ]; then
	msg "Loading PF ruleset from /etc/pf.conf"
	kldload -n pf
	pfctl -q -F all -f /etc/pf.conf || emergency_shell
	pfctl -eq || emergency_shell
fi
