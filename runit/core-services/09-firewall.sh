if [ -e "${pf_rules}" ]; then
	msg "Loading '${pf_rules}'..."
	pfctl -f ${pf_rules} ${pf_flags}
fi

if [ "${firewall_enable}" = "YES" ]; then
	service ipfw onestart
fi
