[ -r /etc/ctl.conf ] || return 1

# ctld(8) always forks into the background.  It cannot be properly
# supervised, so we start it now.  We always use the newer UCL-based
# configuration format.

msg "Starting iSCSI target daemon"
/usr/sbin/ctld -u -f /etc/ctl.conf
