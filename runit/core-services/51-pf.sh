if [ -e "/etc/pf.conf" ]; then
	msg "Loading PF ruleset from '/etc/pf.conf'..."
	kldload pf
	pfctl -q -F all -f /etc/pf.conf || emergency_shell
fi
