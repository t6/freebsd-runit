[ -n "${JAILED}" ] && return 0
echo "=> Setting up loopback interface"
ifconfig lo0 inet 127.0.0.1/8 alias
ifconfig lo0 up
