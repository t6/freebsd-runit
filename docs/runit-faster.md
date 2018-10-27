<!DOCTYPE html>
<link rel="stylesheet" type="text/css" href="buttondown.css">
<title>runit-faster</title>

# runit-faster, a runit based replacement for init(8) and rc(8) for your workstation

Based on the [init scripts from Void Linux](https://github.com/voidlinux/void-runit)

WARNING: This is only an experiment for now. Please do not take it too
seriously. Also it might cripple your computer, eat your data, etc.

# Why?

I like runit.  Let us experiment and see how hard it would be to
completely initialize FreeBSD with it and what it is like in daily
usage.

# System initialization / Setup as PID 1

Please see runit-faster(7).

# Network setup
It is recommended to disable `/etc/rc.d/netif` managed network
interfaces completely and use one of the dhclient services or do
manual network setup instead.

```
netif_enable="NO"
```
Also make sure to remove or comment out any `ifconfig_X="... DHCP
..."` lines in `/etc/rc.conf` to prevent `devd(8)` from autostarting
`dhclient(8)`.

## Setting up wireless networking with link failover
Here we setup `lagg0` with `re0` as master interface and `wlan0` as
backup interface.  We use the `dhclient-lagg0` runit service that will
attempt to run `dhclient(8)` on `lagg0`.  It is under supervision by
runit and the service will be restarted when `dhclient(8)` exits.  For
this to work we have to make that sure that the interfaces are
destroyed first should they already exist.

It is assumed that `/etc/wpa_supplicant.conf` is already setup.

```
$ cat <<EOF > /usr/local/etc/sv/dhclient-lagg0/conf
set -e
ifconfig wlan0 destroy > /dev/null 2>&1 || true
ifconfig lagg0 destroy > /dev/null 2>&1 || true

ifconfig wlan0 create wlandev iwm0 country DE
ifconfig wlan0 inet6 -ifdisabled accept_rtadv up
ifconfig re0 inet6 -ifdisabled accept_rtadv up

ifconfig lagg0 create laggproto failover laggport re0 laggport wlan0 up
EOF
$ ln -s /usr/local/etc/sv/wpa_supplicant /var/service
$ ln -s /usr/local/etc/sv/dhclient-lagg0 /var/service
$ ln -s /usr/local/etc/sv/rtsold /var/service
```

If it not clear that an interface is available yet e.g. because of
using an USB ethernet device or similar, it can be polled for like
this:

```
# Wait for ue0
ifconfig ue0 > /dev/null 2>&1 || exit 1
```

## Static IP
```
$ cat <<EOF > /usr/local/etc/runit/local
#!/bin/sh
ifconfig re0 inet 192.168.0.2/24 up
route add default 192.168.0.1
EOF
$ chmod +x /usr/local/etc/runit/local
```

## netif based setup

To keep using the normal FreeBSD rc.conf-based networking setup:

```
$ cat <<EOF > /usr/local/etc/runit/local
#!/bin/sh
service netif quietstart
service routing quietstart
# or simply use /etc/netstart to run every networking related
# rc.d script in the right order.
EOF
$ chmod +x /usr/local/etc/runit/local
```

# Desktop services

Enable D-Bus, DSBMD, xdm:

```
$ ln -s /usr/local/etc/sv/dbus /var/service
$ ln -s /usr/local/etc/sv/dsbmd /var/service
$ ln -s /usr/local/etc/sv/xdm /var/service
```

# Console keyboard layout and font setup

The keyboard layout and console font should be set directly via
`kbdcontrol(1)` and `vidcontrol(1)` in either
`/usr/local/etc/runit/local` or a custom core service
e.g. `/usr/local/etc/runit/core-services/12-console.sh` to set the
keyboard layout and console font as early as possible after loading
kernel modules

```
$ cat <<EOF > /usr/local/etc/runit/core-services/12-console.sh
kbdcontrol -l us < /dev/ttyv0
for ttyv in /dev/ttyv*; do
	vidcontrol -f terminus-b32 < ${ttyv} > ${ttyv}
done
EOF
```

# Autologin to Xfce

For bash/oksh/sh add this to `~/.profile`:
```
if [ -z "$DISPLAY" ] && [ "$(tty)" == "/dev/ttyv0" ]; then
	exec startxfce4
fi
```
Create an autologin entry in `/etc/gettytab`:
```
al.Pctobias:\
	:al=tobias:tc=Pc
```
Then setup getty to use it:
```
echo "TYPE=al.Pctobias" > /usr/local/etc/sv/getty-ttyv0/conf
```
Make sure to enable and/or restart `getty-ttyv0` afterwards.

As services start concurrently it might be a good idea to check for
service availability e.g. a running D-Bus and DSBMD before starting
your X session to prevent situations where the daemons start after
your X session.  Append this to `/usr/local/etc/sv/getty-ttyv0/conf`:
```
sv check dbus > /dev/null || exit 1
sv check dsbmd > /dev/null || exit 1
```

# Rebooting and powering off

`reboot(8)`, `halt(8)`, `poweroff(8)`, `shutdown(8)` will not work
correctly with runit because of the way they send signals to PID 1.
`runit-init 6` can be used to reboot the system and `runit-init 0` to
power it off.

# Jails

`runit-faster` will create a `jail0` interface in the 192.168.95.0/24
network by default.  The host gets IP 192.168.95.1.  This can be used
this to very quickly setup jails.  You can change the network and IP
settings by editing
`/usr/local/etc/runit/core-services/44-jail-network.sh`.

Setup NAT in `/etc/pf.conf`
```
jail_http_ip = 192.168.95.2

nat pass on $ext_if from runit-jail:network to any -> $ext_if
rdr pass on $ext_if proto tcp from any to $ext_if port { https, http } \
	-> $jail_http_ip
```

Clone `jail-template` on the host:
```
mkdir /usr/local/etc/sv/local
svclone /usr/local/etc/sv/jail-template /usr/local/etc/sv/local/jail@http
```

Modify `/usr/local/etc/sv/local/jail@http/jail.conf` to suite your needs
```
http {
	path = /usr/jails/$name;
	host.hostname = $name.example.com;
	mount.devfs;
	mount.fstab = "/var/service/jail@$name/fstab";
	exec.start = "/usr/local/etc/runit/jail start";
	exec.stop = "/usr/local/etc/runit/jail stop";
	ip4.addr = "jail0|192.168.95.2/24";
}
```

If you change `path` in `jail.conf` from the default also make sure to set it in
`/usr/local/etc/sv/local/jail@http/conf` as well:
```
ROOT=/path/to/jail
```

Setup a basic jail
```
bsdinstall jail /usr/jails/http
```

Install and enable `nginx` and `runit-faster` in the jail
```
pkg -c /usr/jails/http install nginx runit-faster
for s in newsyslog nginx syslogd; do
	ln -s /usr/local/etc/sv/${s} /usr/jails/http/usr/local/etc/runit/runsvdir/default
done
```

Finally enable the jail on the host
```
ln -s /usr/local/etc/sv/local/jail@http /var/service
```

# If things go wrong...

* Booting in single user mode boots to an emergency shell.
* The old init can be temporarily reverted back to by `set
  init_path=/rescue/init` at the loader prompt.
