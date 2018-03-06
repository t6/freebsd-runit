[ -n "${JAILED}" ] && [ $(sysctl -n security.jail.set_hostname_allowed) -eq 0 ] && return 0

if [ -r "/usr/local/etc/runit/hostname" ]; then
	_hostname=$(cat /usr/local/etc/runit/hostname)
elif [ -n "$(kenv runit.hostname 2> /dev/null)" ]; then
	_hostname=$(kenv runit.hostname)
else
	msg_warn "Didn't setup a hostname!"
	return 0
fi

msg "Setting hostname to '${_hostname}'..."
hostname "${_hostname}"
