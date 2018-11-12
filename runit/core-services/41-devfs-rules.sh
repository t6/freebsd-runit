[ -n "$JAILED" ] && return 0

msg "Loading devfs rules"

awk 'BEGIN {
	FS="="
	ruleset_num = -1
	ruleset_name = ""
	print "set -eu"
}

/^#/ || /^[[:blank:]]*$/ {
	next
}

/^\[.*=[0-9]*\]$/ {
	ruleset_name = substr($1, 2, length($1) - 1)
	ruleset_num = substr($2, 1, length($2) - 1)
	rulesets[ruleset_name] = ruleset_num
	printf "%s=%s\n", ruleset_name, ruleset_num
	printf "devfs rule -s $%s delset\n", ruleset_name
	next
}

ruleset_num != -1 {
	printf "devfs rule -s $%s %s\n", ruleset_name, $0
}

END {
	if (rulesets["runit_devfs_rules"] != "") {
		print "devfs ruleset $runit_devfs_rules"
		print "devfs rule applyset"
	}
}' /etc/defaults/devfs.rules "$([ -r /etc/devfs.rules ] && echo /etc/devfs.rules)" | sh
