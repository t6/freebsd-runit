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

# If things go wrong...

* Booting in single user mode boots to an emergency shell.
* The old init can be temporarily reverted back to by `set
  init_path=/rescue/init` at the loader prompt.
