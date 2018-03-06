_hostname=$(sysrc -qn hostname)
if [ -n "${_hostname}" ]; then
	msg "Setting hostname to '${_hostname}'..."
	hostname "${_hostname}"
else
	msg_warn "Didn't setup a hostname!"
fi
