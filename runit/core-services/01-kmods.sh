[ -n "$VIRTUALIZATION" ] && return 0

msg "Loading kernel modules..."
local _kld
for _kld in $kld_list ; do
	load_kld -e ${_kld}.ko $_kld
done
echo
