FIND?=		find
GIT?=		git
GZIP_CMD?=	gzip
LN?=		ln
MKDIR?=		mkdir -p
PRINTF?=	printf
SED?=		sed
TAR?=		tar

PREFIX?=	/usr/local
RUNITDIR?=	${DESTDIR}${PREFIX}/etc/runit
SVDIR?=		${DESTDIR}${PREFIX}/etc/sv
SVLOCALDIR?=	${DESTDIR}${PREFIX}/etc/sv-local

GETTYSV=	getty-ttyv0 getty-ttyv2 getty-ttyv3 getty-ttyv4 getty-ttyv5 \
		getty-ttyv6 getty-ttyv7 getty-ttyv8
GETTYSU=	getty-ttyu0 getty-ttyu1 getty-ttyu2 getty-ttyu3
NETIFS=		bge bridge em fxp gem igb lagg re rl vtnet wlan

install:
	@${MKDIR} ${RUNITDIR} ${SVDIR} ${SVLOCALDIR}
	@${TAR} -C runit --exclude .gitkeep -cf - . | ${TAR} -C ${RUNITDIR} -xf -
	@${TAR} -C sv -cf - . | ${TAR} -C ${SVDIR} -xf -
	@${FIND} ${RUNITDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${PREFIX}/,g' {} \;
	@${FIND} ${SVDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${PREFIX}/,g' {} \;
.for netif in ${NETIFS}
.for i in 0 1 2
	@${MKDIR} ${SVDIR}/dhclient-${netif}${i}
	@cd ${SVDIR}/dhclient-${netif}${i} && \
		${LN} -sf ../dhclient-sample/run
.endfor
.endfor
# Create convenient getty services for every terminal device that is
# by default in /etc/ttys
.for getty in ${GETTYSV} ${GETTYSU}
	@${MKDIR} ${SVDIR}/${getty}
	@cd ${SVDIR}/${getty} && \
		${LN} -sf ../getty-ttyv1/run && \
		${LN} -sf ../getty-ttyv1/finish
.endfor
.for getty in ${GETTYSU}
	@${PRINTF} "TERM='vt100'\nTYPE='3wire'\n" > ${SVDIR}/${getty}/conf
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
	@tag=$$(${GIT} tag); ver=$${tag#v*}; \
		${GIT} archive --format=tar \
			--prefix=freebsd-runit-$$ver/ \
			--output=freebsd-runit-$$ver.tar \
			$$tag && \
		${GZIP_CMD} freebsd-runit-$$ver.tar
