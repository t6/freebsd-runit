FIND?=		find
GIT?=		git
GZIP_CMD?=	gzip
LN?=		ln
MKDIR?=		mkdir -p
PRINTF?=	printf
SED?=		sed
TAR?=		tar

LOCALBASE?=	/usr/local
PREFIX?=	/usr/local
RUNITDIR?=	${DESTDIR}${PREFIX}/etc/runit
SVDIR?=		${DESTDIR}${PREFIX}/etc/sv

GETTYSV=	ttyv0 ttyv2 ttyv3 ttyv4 ttyv5 ttyv6 ttyv7 ttyv8
GETTYSU=	ttyu0 ttyu1 ttyu2 ttyu3
NETIFS=		bge bridge em fxp gem igb lagg re rl vtnet wlan

install:
	@${MKDIR} ${RUNITDIR} ${SVDIR}
	@${TAR} -C runit --exclude .gitkeep -cf - . | ${TAR} -C ${RUNITDIR} -xf -
	@${TAR} -C sv -cf - . | ${TAR} -C ${SVDIR} -xf -
	@${FIND} ${RUNITDIR} -type f -exec ${SED} -i '' -e 's,/usr/local,${PREFIX},g' -e 's,//etc,/etc,' {} \;
	@${FIND} ${SVDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${LOCALBASE}/,g' {} \;
.for netif in ${NETIFS}
.for i in 0 1 2
	@${MKDIR} ${SVDIR}/dhclient-${netif}${i}
	@cd ${SVDIR}/dhclient-${netif}${i} && \
		${LN} -sf ../dhclient-sample/run
.endfor
.endfor
# Create convenient getty services for every terminal device that is
# by default in /etc/ttys
.for tty in ${GETTYSV} ${GETTYSU}
	@${MKDIR} ${SVDIR}/getty-${tty}
	@cd ${SVDIR}/getty-${tty} && \
		${LN} -sf ../getty-ttyv1/run && \
		${LN} -sf ../getty-ttyv1/finish
.endfor
.for tty in ${GETTYSU}
	@${PRINTF} "TERM='vt100'\nTYPE='3wire'\n" > ${SVDIR}/getty-${tty}/conf
.endfor
# Link supervise dir of services to /var/run/runit to potentially
# support systems with read-only filesystems.
	@cd ${SVDIR} && ${FIND} -d . -type d -exec /bin/sh -euc '\
		dir=$${1#./*}; \
		[ "$${dir}" = "." ] && exit 0; \
		${LN} -sf /var/run/runit/supervise.$$(echo $${dir} | ${SED} "s,/,-,g") \
			$${dir}/supervise' \
		SUPERVISE {} \;

archive:
	@tag=$$(${GIT} tag --contains HEAD); ver=$${tag#v*}; \
		${GIT} archive --format=tar \
			--prefix=freebsd-runit-$$ver/ \
			--output=freebsd-runit-$$ver.tar \
			$$tag && \
		${GZIP_CMD} freebsd-runit-$$ver.tar
