[ -r /dev/mixer0 ] || return 0
msg "Restoring soundcard mixer values"
for dev in /dev/mixer*; do 
	if [ -r ${dev} ] && [ -r "/var/db/${dev##*/}-state" ]; then
		/usr/sbin/mixer -f ${dev} $(cat "/var/db/${dev##*/}-state") > /dev/null
	fi
done
