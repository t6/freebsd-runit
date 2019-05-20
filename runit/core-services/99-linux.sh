[ -d "/compat/linux/proc" ] || return 1
[ -d "/compat/linux/sys" ] || return 1

echo "=> Mounting Linux pseudo filesystems"

if [ -d "/compat/linux/dev" ]; then
	echo "WARNING: /compat/linux/dev should not exist.  It shadows /dev"
	echo "         and Linux applications will be unable to access devices."
fi

_fstab_shm=
if [ ! -L "/dev/shm" ] && [ -d "/dev/shm" ]; then
	# If /dev/shm is a real directory mount tmpfs on it.  Some
	# Linux applications stat it to check if it is a directory.
	_fstab_shm="none /dev/shm tmpfs rw 0 0"
else
	# Some FreeBSD versions do not have a /dev/shm directory
	# yet, so as a fallback symlink it to a tmpfs instead.
	mkdir -p /var/run/runit/dev/shm
	ln -sF /var/run/runit/dev/shm /dev/shm
fi

# Make sure to not mount the filesystems again in case 31-mount or
# 95-mount-late already did it.
cat <<EOF | env PATH_FSTAB=/dev/stdin mount -a
none /dev/fd fdescfs rw,linrdlnk 0 0
none /compat/linux/proc linprocfs rw 0 0
none /compat/linux/sys linsysfs rw 0 0
${_fstab_shm}
EOF
