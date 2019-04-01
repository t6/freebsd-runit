[ -r /usr/ports/Mk/Scripts/ports_env.sh ] || return 0

# /var/run/runit/ports-env can be sourced to speed up ports related
# things.  If you update your ports checkout or change something
# in /etc/make.conf you might have to rerun this script.
echo "=> Caching ports collection environment"
# shellcheck disable=SC1004
su -m nobody -c 'env MAKE=/usr/bin/make \
	PORTSDIR="/usr/ports" \
	SCRIPTSDIR="/usr/ports/Mk/Scripts" \
	/bin/sh "/usr/ports/Mk/Scripts/ports_env.sh"' \
	>/var/run/runit/ports-env
