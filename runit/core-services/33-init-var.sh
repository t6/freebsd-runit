echo "=> Populating /var"

mkdir -p /var/run
[ -z "${JAILED}" ] && mount -t tmpfs -o size=8m tmpfs /var/run
/usr/sbin/mtree -deiU -f /etc/mtree/BSD.var.dist -p /var >/dev/null

# Make sure we have /var/log/utx.lastlogin and /var/log/utx.log files
if [ ! -f /var/log/utx.lastlogin ]; then
	install -m644 /dev/null /var/log/utx.lastlogin
fi
if [ ! -f /var/log/utx.log ]; then
	install -m644 /dev/null /var/log/utx.log
fi

mkdir -p /var/run/runit/runsvdir
install -m100 /dev/null /var/run/runit/stopit
