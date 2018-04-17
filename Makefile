FIND?=		find
GIT?=		git
GZIP_CMD?=	gzip
INSTALL_MAN?=	install -m 444
INSTALL_SCRIPT?=	install -m 555
LN?=		ln
MKDIR?=		mkdir -p
PRINTF?=	printf
SED?=		sed
TAR?=		tar

LOCALBASE?=	/usr/local
PREFIX?=	/usr/local
RUNITDIR?=	${PREFIX}/etc/runit
SVDIR?=		${PREFIX}/etc/sv
SVDIR_REL!=	echo ${SVDIR} | ${SED} 's@[^/]*@..@g'

GETTYSV=	ttyv0 ttyv2 ttyv3 ttyv4 ttyv5 ttyv6 ttyv7 ttyv8
GETTYSU=	ttyu0 ttyu1 ttyu2 ttyu3
NETIFS=		bge bridge em fxp gem igb lagg re rl vtnet wlan

all: docs

install:
	@${MKDIR} ${DESTDIR}${PREFIX}/bin ${DESTDIR}${RUNITDIR} ${DESTDIR}${SVDIR}
	@${INSTALL_SCRIPT} bin/svclone ${DESTDIR}${PREFIX}/bin
	@${MKDIR} ${DESTDIR}${PREFIX}/man/man8
	@${INSTALL_MAN} docs/svclone.8 ${DESTDIR}${PREFIX}/man/man8
	@${TAR} -C runit --exclude .gitkeep -cf - . | ${TAR} -C ${DESTDIR}${RUNITDIR} -xf -
	@${TAR} -C sv --exclude supervise -cf - . | ${TAR} -C ${DESTDIR}${SVDIR} -xf -
	@${FIND} ${DESTDIR}${RUNITDIR} -type f -exec ${SED} -i '' \
		-e 's,/usr/local/etc/runit,${RUNITDIR},g' \
		-e 's,//etc,/etc,' \
		-e 's,/usr/local,${LOCALBASE},g' {} \;
	@${FIND} ${DESTDIR}${SVDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${LOCALBASE}/,g' {} \;
.for netif in ${NETIFS}
.for i in 0 1 2
	@${MKDIR} ${DESTDIR}${SVDIR}/dhclient-${netif}${i}/log
	@cd ${DESTDIR}${SVDIR}/dhclient-${netif}${i} && \
		${LN} -sf ../dhclient-template/run && \
		cd log && ${LN} -sf ../../dhclient-template/log/run
.endfor
.endfor
# Create convenient getty services for every terminal device that is
# by default in /etc/ttys
.for tty in ${GETTYSV} ${GETTYSU}
	@${MKDIR} ${DESTDIR}${SVDIR}/getty-${tty}
	@cd ${DESTDIR}${SVDIR}/getty-${tty} && \
		${LN} -sf ../getty-ttyv1/run && \
		${LN} -sf ../getty-ttyv1/finish
.endfor
.for tty in ${GETTYSU}
	@${PRINTF} "TERM='vt100'\nTYPE='3wire'\n" > ${DESTDIR}${SVDIR}/getty-${tty}/conf
.endfor
# Link supervise dir of services to /var/run/runit to potentially
# support systems with read-only filesystems.
	@cd ${DESTDIR}${SVDIR} && ${FIND} -d . -type d -exec /bin/sh -euc '\
		dir=$${1#./*}; \
		[ "$${dir}" = "." ] && exit 0; \
		${LN} -sf ${SVDIR_REL}/var/run/runit/supervise.$$(echo $${dir} | ${SED} "s,/,-,g") \
			$${dir}/supervise' \
		SUPERVISE {} \;

archive:
	@tag=$$(${GIT} tag --contains HEAD); ver=$${tag#v*}; \
		${GIT} archive --format=tar \
			--prefix=freebsd-runit-$$ver/ \
			--output=freebsd-runit-$$ver.tar \
			$$tag && \
		${GZIP_CMD} freebsd-runit-$$ver.tar

docs: docs/runit-faster.html

docs/runit-faster.html: docs/runit-faster.md
	cmark docs/runit-faster.md > docs/runit-faster.html

.PHONY: all archive docs
