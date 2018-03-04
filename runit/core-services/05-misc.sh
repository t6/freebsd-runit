msg "Initializing random seed..."
service random onestart

msg "Setting up loopback interface..."
ifconfig lo0 inet 127.0.0.1/8 alias

if [ -n "${hostname}" ]; then
	msg "Setting up hostname to '${hostname}'..."
	hostname "${hostname}"
else
	msg_warn "Didn't setup a hostname!"
fi
