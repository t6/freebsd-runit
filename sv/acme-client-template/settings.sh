[ -r conf ] && . ./conf
# acme-client@<domain>[@<altname1>[@<alt2>[@<altN>]]]
myifs="${IFS}"
IFS="@"
i=0
for f in ${PWD}; do
	case ${i} in
	0) ;;
	1) domain=${f} ;;
	*) altnames="${altnames} ${f}" ;;
	esac
	i=$((i + 1))
done
IFS="${myifs}"
: "${CHALLENGEDIR:=/usr/jails/http/usr/local/www/acme-client/${domain}}"
: "${SSLDIR:=/usr/local/etc/ssl}"
: "${ALTNAMES:=}"
