# Force different defaults than what FreeBSD has.  Can be overwritten
# again via /etc/sysctl.conf

msg "Setting system defaults..."

# - Let network interfaces accept router advertisments by default
# - Make FreeBSD installer security options opt-out
# - Adapt the good bits from https://vez.mrsk.me/freebsd-defaults.txt
# - Use a better congestion control algorithm than newreno
kldload cc_cubic > /dev/null 2>&1 || true
sysctl \
	net.inet.tcp.cc.algorithm=cubic \
	net.inet6.ip6.accept_rtadv=1 \
	security.bsd.see_other_gids=0 \
	security.bsd.see_other_uids=0 \
	security.bsd.stack_guard_page=1 \
	security.bsd.unprivileged_proc_debug=0 \
	security.bsd.unprivileged_read_msgbuf=0 \
	kern.randompid=1 \
	net.inet.icmp.drop_redirect=1 \
	net.inet.ip.check_interface=1 \
	net.inet.ip.process_options=0 \
	net.inet.ip.random_id=1 \
	net.inet.ip.redirect=0 \
	net.inet.sctp.blackhole=2 \
	net.inet.tcp.blackhole=2 \
	net.inet.tcp.drop_synfin=1 \
	net.inet.tcp.icmp_may_rst=0 \
	net.inet.udp.blackhole=1 \
	security.bsd.hardlink_check_gid=1 \
	security.bsd.hardlink_check_uid=1

# XXX: Check if the hardlink_check options really break Poudriere builds
