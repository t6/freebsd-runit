[ -n "${JAILED}" ] && return 0

msg "Checking filesystems..."
service fsck onestart
