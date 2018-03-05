[ -n "$VIRTUALIZATION" ] && return 0

msg "Loading kernel modules..."
for _kld in $(sysrc -n kld_list); do
	load_kld -e ${_kld}.ko $_kld
done
echo
