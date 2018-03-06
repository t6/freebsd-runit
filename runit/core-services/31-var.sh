msg "Populating /var directory..."

if [ -d /var/run ] && [ -d /var/db ] && [ -d /var/empty ]; then
	true
else
	/usr/sbin/mtree -deiU -f /etc/mtree/BSD.var.dist -p /var > /dev/null
fi

# Make sure we have /var/log/utx.lastlogin and /var/log/utx.log files
if [ ! -f /var/log/utx.lastlogin ]; then
	install -m644 /dev/null /var/log/utx.lastlogin
fi
if [ ! -f /var/log/utx.log ]; then
	install -m644 /dev/null /var/log/utx.log
fi

mkdir -p /var/run/runit
rm -rf /var/run/runit/*
install -m100 /dev/null /var/run/runit/stopit
