<!DOCTYPE html>
<link rel="stylesheet" type="text/css" href="buttondown.css">
<title>runit-faster</title>

# runit-faster, a runit based replacement for init(8) and rc(8) for your workstation

Roughly based on the [init scripts from Void Linux](https://github.com/voidlinux/void-runit)

WARNING: This is only an experiment for now. Please do not take it too
seriously. Also it might cripple your computer, eat your data, etc.

# Why?

I like runit.  Let us experiment and see how hard it would be to
completely initialize FreeBSD with it and what it is like in daily
usage.

# System initialization

Runit initializes the system in two stages.  The first stage will run
a bunch of core services (`/etc/runit/core-services`), one time system
tasks:

```
11-kld.sh             Loads kernel modules
11-set-defaults.sh    Sets some system defaults
21-swap.sh            Enables swap
31-enable-dumpdev.sh  Set the dump device 
31-fsck.sh            Run fsck
31-mount.sh           Mounts all early filesystem, also ZFS
31-var.sh             Make sure that /var has the right structure
41-entropy.sh         Initialize the entropy harvester
41-hostid.sh          Generate a hostid
41-hostname.sh        Sets the hostname
41-ldconfig.sh        Sets up the shared library cache
41-loopback.sh        Create lo0
41-mixer.sh           Restore soundcard mixer values
41-nextboot.sh        Prune nextboot configuration
41-rctl.sh            Apply resource limits from /etc/rctl.conf
51-pf.sh              Enable PF and load /etc/pf.conf
99-cleanup.sh         Clean /tmp
99-mount-late.sh      Mount all late filesystems
```

The core sources will be sourced in lexicographic order.  Users can
insert their own core services in the right places by creating a file
with an even number prefix.

Stage 2 will look up the runlevel in the `runit.runlevel` kenv and
link `/etc/runit/runsvdir/$runlevel` to `/var/service`.  It will then
run `runsvdir(8)` on it which starts all defined services for the
runlevel and starts supervising them.

runit-faster comes with some services out of the box for the user's
convenience in `/usr/local/etc/sv`.  These can be linked to the
runlevel to enable them.

# Installation

```
pkg install runit-faster
```
or from ports
```
make -C /usr/ports/sysutils/runit-faster install
```

The port normally assumes that `/usr/local` is located on the same
partition as the root filesystem.  If that is not the case please
compile the port with the `ROOT` option on.  Binaries and the
necessary configuration files will then be installed into `/etc/runit`
and `/sbin` instead of in `/usr/local/etc/runit` and
`/usr/local/sbin`.  In the rest of this howto we will always refer to
`/etc/runit` directly instead of `/usr/local/etc/runit` for brevity's
sake.  Please adjust the paths below accordingly.

Adjust `/boot/loader.conf` and tell the kernel to attempt to use
`/sbin/runit-init` as PID 1

```
init_path="/sbin/runit-init:/usr/local/sbin/runit-init:/rescue/init"
```

No service is enabled by default.  Some basic ones must be enabled, at
the very least one getty service in the `default` runlevel to get a
login prompt after rebooting.

```
$ ln -s /usr/local/etc/sv/devd /etc/runit/runsvdir/default
$ ln -s /usr/local/etc/sv/getty-ttyv0 /etc/runit/runsvdir/default
$ ln -s /usr/local/etc/sv/syslogd /etc/runit/runsvdir/default
```

The runlevel can be selected via the `runit.runlevel` kenv.  If
omitted a value of `default` is used.

Settings from `/etc/rc.conf` will *not* be applied when using
runit-faster. The hostname has to be set via the `runit.hostname` kenv
or in `/etc/runit/hostname`:

```
$ echo my-hostname > /etc/runit/hostname
```

`kld_list` for loading kernel modules should be migrated to
`/etc/runit/modules`.  They will be loaded as a first step when the
system initializes.

```
$ sysrc kld_list
kld_list: /boot/modules/i915kms.ko if_iwm ichsmb vboxdrv vboxnetflt vboxnetadp
$ cat <<EOF > /etc/runit/modules
/boot/modules/i915kms.ko
vboxdrv
vboxnetflt
vboxnetadp
EOF
```

Now reboot!

# Enabling basic system services

Some basic system maintenance tasks must be setup.  This can be done by
either enabling cron:

```
$ ln -s /usr/local/etc/sv/cron /var/service
```

or by using the `snooze(1)` based replacements for them:

```
$ ln -s /usr/local/etc/sv/adjkerntz /var/service
$ ln -s /usr/local/etc/sv/periodic-daily /var/service
$ ln -s /usr/local/etc/sv/periodic-weekly /var/service
$ ln -s /usr/local/etc/sv/periodic-monthly /var/service
$ ln -s /usr/local/etc/sv/save-entropy /var/service
```

If the `snooze(1)` services are used and cron is also needed the
corresponding system maintenance tasks should be disabled in
`/etc/crontab`.

To mimic a default FreeBSD console setup, more getty services need to
be enabled.  This will enable all virtual terminals that are normally
enabled in `/etc/ttys`:

```
$ ln -s /usr/local/etc/sv/getty-ttyv1 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv2 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv3 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv4 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv5 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv6 /var/service
$ ln -s /usr/local/etc/sv/getty-ttyv7 /var/service
```

# Network setup
It is recommended to disable `/etc/rc.d/netif` managed network
interfaces completely and use one of the dhclient services or do
manual network setup instead.

## Setting up wireless networking with link failover
Here we setup `lagg0` with `re0` as master interface and `wlan0` as
backup interface.  We use the `dhclient-lagg0` runit service that will
attempt to run `dhclient(8)` on `lagg0`.  It is under supervision by
runit and the service will be restarted when `dhclient(8)` exits.  For
this to work we have to make that sure that the interfaces are
destroyed first should they already exist.

It is assumed that `/etc/wpa_supplicant.conf` is already setup.  We
assign interfaces to the `egress` group to make them easy to address
in `/etc/pf.conf`.

```
$ cat <<EOF > /usr/local/etc/sv/dhclient-lagg0/conf
set -e
ifconfig wlan0 destroy > /dev/null 2>&1 || true
ifconfig lagg0 destroy > /dev/null 2>&1 || true

ifconfig wlan0 create wlandev iwm0 country DE
ifconfig wlan0 inet6 -ifdisabled accept_rtadv group egress up
ifconfig re0 inet6 -ifdisabled accept_rtadv group egress up

ifconfig lagg0 create laggproto failover laggport re0 laggport wlan0 up
ifconfig lagg0 group egress
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
$ cat <<EOF > /etc/runit/local
#!/bin/sh
ifconfig re0 inet 192.168.0.2/24 up
route add default 192.168.0.1
EOF
$ chmod +x /etc/runit/local
```

## netif based setup

To keep using the normal FreeBSD rc.conf-based networking setup:

```
$ cat <<EOF > /etc/runit/local
#!/bin/sh
service netif quietstart
service routing quietstart
# or simply use /etc/netstart to run every networking related
# rc.d script in the right order.
EOF
$ chmod +x /etc/runit/local
```

# Desktop services

Enable D-Bus, dsbmd, xdm:

```
$ ln -s /usr/local/etc/sv/dbus /var/service
$ ln -s /usr/local/etc/sv/dsbmd /var/service
$ ln -s /usr/local/etc/sv/xdm /var/service
```

# Console keyboard layout and font setup

The keyboard layout and console font should be set directly via
`kbdcontrol(1)` and `vidcontrol(1)` in either `/etc/runit/local` or a
custom core service e.g. `/etc/runit/core-services/00-console.sh` to
set the keyboard layout and console font as early as possible

```
$ cat <<EOF > /etc/runit/core-services/00-console.sh
kdbcontrol -l us < /dev/ttyv0
for ttyv in /dev/ttyv*; do
	vidcontrol -f terminus-b32 < ${ttyv} > ${ttyv}
done
EOF
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
