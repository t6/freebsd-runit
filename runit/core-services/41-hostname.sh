if [ -r "/usr/local/etc/runit/hostname" ]; then
	_hostname=$(cat /usr/local/etc/runit/hostname)
	msg "Setting hostname to '${_hostname}'..."
	hostname "${_hostname}"
else
	msg_warn "Didn't setup a hostname!"
fi
