[ -n "$VIRTUALIZATION" ] && return 0

msg "Starting devd..."
devd $(sysrc -qn devd_flags) || emergency_shell
