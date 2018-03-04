[ -n "$VIRTUALIZATION" ] && return 0

msg "Starting devd..."
devd ${devd_flags}
