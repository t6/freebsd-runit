if [ -e "/etc/rctl.conf" ]; then
	msg "Applying resource limits from /etc/rctl.conf"
	# shellcheck disable=SC2034,SC2162
	while read var comments; do
		case ${var} in
		\#* | '') ;;
		*) echo "${var}" ;;
		esac
	done </etc/rctl.conf | xargs rctl -a
fi
