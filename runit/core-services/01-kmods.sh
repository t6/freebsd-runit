[ -n "$VIRTUALIZATION" ] && return 0

msg "Loading kernel modules..."
_kld_list=$(sysrc -qn kld_list)
for _kld in $_kld_list ; do
	load_kld -e ${_kld}.ko $_kld
done
