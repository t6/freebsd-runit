msg "Initializing random seed..."
service random onestart

msg "Configuring the shared library cache..."
service ldconfig onestart

msg "Setting up loopback interface..."
ifconfig lo0 inet 127.0.0.1/8 alias

if [ -n "${hostname}" ]; then
	msg "Setting hostname to '${hostname}'..."
	hostname "${hostname}"
else
	msg_warn "Didn't setup a hostname!"
fi

[ -n "$VIRTUALIZATION" ] && return 0

msg "Starting devd..."
devd $(sysrc -n devd_flags) || emergency_shell
