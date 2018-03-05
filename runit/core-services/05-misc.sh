msg "Pruning nextboot configuration..."
/sbin/nextboot -D

msg "Configuring the shared library cache..."
service ldconfig onestart

msg "Setting up loopback interface..."
ifconfig lo0 inet 127.0.0.1/8 alias

_hostname=$(sysrc -qn hostname)
if [ -n "${_hostname}" ]; then
	msg "Setting hostname to '${_hostname}'..."
	hostname "${_hostname}"
else
	msg_warn "Didn't setup a hostname!"
fi

if [ -e "/etc/pf.conf" ]; then
	msg "Loading PF ruleset from '/etc/pf.conf'..."
	pfctl -f /etc/pf.conf $(conf pfctl_flags)
fi
