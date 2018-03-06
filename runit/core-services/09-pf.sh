if [ -e "/etc/pf.conf" ]; then
	msg "Loading PF ruleset from '/etc/pf.conf'..."
	pfctl -f /etc/pf.conf $(conf pfctl_flags)
fi
