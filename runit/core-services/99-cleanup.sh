msg "Purging '/tmp'..."
find -x /tmp/. ! -name . \
     ! \( -name .sujournal -type f -user root \) \
     ! \( -name .snap -type d -user root \) \
     ! \( -name lost+found -type d -user root \) \
     ! \( \( -name quota.user -or -name quota.group \) \
     -type f -user root \) \
     -prune -exec rm -rf -- {} +
install -dm1777 /tmp/.X11-unix /tmp/.ICE-unix
