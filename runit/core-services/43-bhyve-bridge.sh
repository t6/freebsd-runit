[ -n "${JAILED}" ] && return 0
ifconfig bridge create name bhyve-bridge0 group runit-managed up
