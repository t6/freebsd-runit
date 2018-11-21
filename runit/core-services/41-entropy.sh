[ -n "${JAILED}" ] && return 0

save_dev_random() {
	oumask=$(umask)
	umask 077
	for f; do
		dd if=/dev/random of="$f" bs=4096 count=1 status=none &&
			chmod 600 "$f"
	done
	umask "${oumask}"
}

feed_dev_random() {
	for f; do
		if [ -f "$f" ] && [ -r "$f" ] && [ -s "$f" ]; then
			if dd if="$f" of=/dev/random bs=4096 2>/dev/null; then
				rm -f "$f"
			fi
		fi
	done
}

msg 'Feeding entropy'

if [ ! -w /dev/random ]; then
	msg_warn "/dev/random is not writeable"
	return 1
fi

# Reseed /dev/random with previously stored entropy.
if [ -d /var/db/entropy ]; then
	feed_dev_random /var/db/entropy/*
fi

feed_dev_random /entropy /var/db/entropy-file
save_dev_random /entropy
save_dev_random /boot/entropy
