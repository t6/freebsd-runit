msg "Configuring the shared library cache"

add_paths() {
	# shellcheck disable=SC2039
	local _lib _ldconfig_dir
	_lib=""
	for i in $1; do
		if [ -r "${i}" ]; then
			_lib="${_lib} ${i}"
		fi
	done
	_ldconfig_dir=""
	for i in $2; do
		if [ -r "${i}" ]; then
			_ldconfig_dir="${_ldconfig_dir} ${i}"
		fi
	done
	shift 2
	if [ -n "${_ldconfig_dir}" ]; then
		# shellcheck disable=SC2038,SC2086
		find ${_ldconfig_dir} -type f | xargs cat | sort -u | xargs ldconfig "$@" ${_lib}
	else
		# shellcheck disable=SC2086
		ldconfig "$@" ${_lib}
	fi
}

add_paths "/lib /usr/lib /usr/lib/compat /usr/local/lib /usr/local/lib/compat/pkg /etc/ld-elf.so.conf" \
	  /usr/local/libdata/ldconfig \
	  -elf -v

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
