[ -n "${JAILED}" ] && return 0

if [ -r /usr/local/etc/runit/modules ]; then
	msg "Loading kernel modules..."
	while read kld; do
		case "${kld}" in
		\#*|'') ;;
		*) kldload "${kld}" ;;
		esac
	done < /usr/local/etc/runit/modules
fi
