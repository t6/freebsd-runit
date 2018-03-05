if sysrc -c netif_enable=YES; then
	service netif onestart
	service routing onestart
fi

if [ -e "/etc/pf.conf" ]; then
	msg "Loading PF ruleset from '/etc/pf.conf'..."
	pfctl -f /etc/pf.conf
fi
