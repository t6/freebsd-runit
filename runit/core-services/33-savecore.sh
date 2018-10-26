[ -n "${JAILED}" ] && return 0
dumpdev=$(/bin/kenv -q dumpdev)
[ -z "${dumpdev}" ] && return 0
savecore -C "${dumpdev}" || return 0

msg "Saving core dump"
savecore -m 10 /var/crash "${dumpdev}"
