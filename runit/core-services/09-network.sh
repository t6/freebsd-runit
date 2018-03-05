if sysrc -c netif_enable=YES; then
	service netif onestart
	service routing onestart
fi

if sysrc -c pf_enable=YES; then
	_pf_rules=$(sysrc -n pf_rules)
	msg "Loading '${_pf_rules}'..."
	pfctl -f ${_pf_rules} $(sysrc -n pf_flags)
fi

if sysrc -c firewall_enable=YES; then
	service ipfw onestart
fi
