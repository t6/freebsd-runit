[ -n "${JAILED}" ] && return 0

if [ -r /usr/local/etc/runit/modules ]; then
	msg "Loading kernel modules"
	while read -r kld; do
		case "${kld}" in
		\#* | '') ;;
		*) kldload -n "${kld}" ;;
		esac
	done </usr/local/etc/runit/modules
fi
