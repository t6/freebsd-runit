#!/bin/sh
[ -r conf ] && . ./conf
# acme-client@<domain>[@<altname1>[@<alt2>[@<altN>]]]
myifs="${IFS}"
IFS="@"
i=0
for f in ${PWD}; do
	case ${i} in
	1) domain=${f} ;;
	*) altnames="${altnames} ${f}" ;;
	esac
	i=$((i + 1))
done
IFS="${myifs}"
: "${CHALLENGEDIR:=/usr/jails/http/usr/local/www/acme-client/${domain}}"
: "${SSLDIR:=/usr/local/etc/ssl}"
: "${ALTNAMES:=}"
install -d -o root -g wheel -m 755 "${SSLDIR}/${domain}"
install -d -m700 -o root -g wheel "${SSLDIR}/${domain}/private"
install -d -o root -g www -m 770 "${CHALLENGEDIR}" 
# shellcheck disable=SC2086
exec /usr/local/bin/acme-client -b \
	-C "${CHALLENGEDIR}" \
	-k "${SSLDIR}/${domain}/private/${domain}.pem" \
	-c "${SSLDIR}/${domain}" \
	-n -N \
	"${domain}" ${altnames} ${ALTNAMES}
