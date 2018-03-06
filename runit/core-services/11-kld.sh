[ -n "${JAILED}" ] && return 0

if [ -r /usr/local/etc/runit/modules ]; then
	msg "Loading kernel modules..."
	_kld_list=$(cat /usr/local/etc/runit/modules)
	for _kld in $_kld_list ; do
		load_kld -e ${_kld}.ko $_kld
	done
fi
