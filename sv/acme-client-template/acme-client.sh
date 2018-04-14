#!/bin/sh
[ -r conf ] && . ./conf
domain=$(echo ${PWD} | awk -F@ '{ print $2 }')
altnames=$(echo ${PWD} | awk -F@ '{ for (i = 3; i <= NF; i++) { print $i }; }')
: ${CHALLENGEDIR:=/usr/jails/http/usr/local/www/acme-client/${domain}}
: ${SSLDIR:=/usr/local/etc/ssl}
: ${ALTNAMES:=}
install -d -o root -g wheel -m 755 "${SSLDIR}/${domain}"
install -d -m700 -o root -g wheel "${SSLDIR}/${domain}/private"
install -d -o root -g www -m 770 "${CHALLENGEDIR}" 
exec /usr/local/bin/acme-client -b \
	-C "${CHALLENGEDIR}" \
	-k "${SSLDIR}/${domain}/private/${domain}.pem" \
	-c "${SSLDIR}/${domain}" \
	-n -N \
	${domain} ${altnames} ${ALTNAMES}
