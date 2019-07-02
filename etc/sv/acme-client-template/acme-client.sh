#!/bin/sh
# shellcheck source=sv/acme-client-template/settings.sh
. ./settings.sh
# shellcheck disable=SC2154
install -d -o root -g wheel -m 755 "${SSLDIR}/${domain}"
# shellcheck disable=SC2154
install -d -m 700 -o root -g wheel "${SSLDIR}/${domain}/private"
install -d -o root -g www -m 770 "${CHALLENGEDIR}"
# shellcheck disable=SC2086,SC2154
exec /usr/local/bin/acme-client -b \
	-C "${CHALLENGEDIR}" \
	-k "${SSLDIR}/${domain}/private/${domain}.pem" \
	-c "${SSLDIR}/${domain}" \
	-n -N \
	"${domain}" ${altnames} ${ALTNAMES}
