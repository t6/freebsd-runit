#!/bin/sh
# shellcheck source=sv/acme-client-template/settings.sh
. ./settings.sh
install -d -o root -g wheel -m 755 "${SSLDIR}/${domain}"
install -d -m 700 -o root -g wheel "${SSLDIR}/${domain}/private"
install -d -o root -g www -m 770 "${CHALLENGEDIR}"
# shellcheck disable=SC2086
exec /usr/local/bin/acme-client -b \
	-C "${CHALLENGEDIR}" \
	-k "${SSLDIR}/${domain}/private/${domain}.pem" \
	-c "${SSLDIR}/${domain}" \
	-n -N \
	"${domain}" ${altnames} ${ALTNAMES}
