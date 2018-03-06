msg "Configuring the shared library cache..."

add_paths() {
	local _LDC _paths
	_LDC="$1"
	_paths="$2"
	for i in $3; do
		if [ -d "${i}" ]; then
			_files=$(find ${i} -type f)
			if [ -n "${_files}" ]; then
				_paths="${_paths} $(cat ${_files} | sort -u)"
			fi
		fi
	done
	for i in ${_paths}; do
		if [ -r "${i}" ]; then
			_LDC="${_LDC} ${i}"
		fi
	done
	shift 3
	ldconfig "$@" ${_LDC}
}

add_paths "/lib /usr/lib" \
	  "/usr/lib/compat /usr/local/lib /usr/local/lib/compat/pkg /etc/ld-elf.so.conf" \
	  /usr/local/libdata/ldconfig \
	  -elf


_paths="/usr/lib32 /usr/lib32/compat"
case $(sysctl -n hw.machine_arch) in
	amd64|powerpc64)
		add_paths "/usr/lib32 /usr/lib32/compat" \
			  /usr/local/libdata/ldconfig32 \
			  -32 -m
		;;
	armv[67])
		add_paths "/usr/libsoft /usr/libsoft/compat /usr/local/libsoft" \
			  /usr/local/libdata/ldconfigsoft \
			  -soft -m
		;;
esac
