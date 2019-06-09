CMARK?=		cmark
FIND?=		find
GIT?=		git
HUB?=		hub
IGOR?=		igor
INSTALL_MAN?=	install -m 444
INSTALL_PROGRAM?=	install -s -m 555
INSTALL_SCRIPT?=	install -m 555
LN?=		ln
MANDOC?=	mandoc
MKDIR?=		mkdir -p
PRINTF?=	printf
SED?=		sed
SHELLCHECK?=	shellcheck
SHFMT?=		shfmt
TAR?=		tar
XARGS?=		xargs
XZ_CMD?=	xz -Mmax

LOCALBASE?=	/usr/local
PREFIX?=	/usr/local
DOCSDIR?=	${PREFIX}/share/doc/runit
RUNITDIR?=	${PREFIX}/etc/runit
SBINDIR?=	${PREFIX}/sbin
SVDIR?=		${PREFIX}/etc/sv

GETTYSV=	ttyv0 ttyv2 ttyv3 ttyv4 ttyv5 ttyv6 ttyv7 ttyv8
GETTYSU=	ttyu0 ttyu1 ttyu2 ttyu3

all:
	echo '#define RUNITDIR "${RUNITDIR}"' > runit/src/runit.local.h
	echo '#define SBINDIR "${SBINDIR}"' >> runit/src/runit.local.h
	echo "${CC} ${CFLAGS}" > runit/src/conf-cc
	echo "${CC}" > runit/src/conf-ld
	cd runit && ./package/compile

install:
	@${MKDIR} ${DESTDIR}${PREFIX}/bin ${DESTDIR}${PREFIX}/sbin ${DESTDIR}${SBINDIR} \
		${DESTDIR}${RUNITDIR} ${DESTDIR}${SVDIR} ${DESTDIR}${DOCSDIR}
	cd runit/command && \
		${INSTALL_PROGRAM} runit runit-init ${DESTDIR}${SBINDIR}
	cd runit/command && \
		${INSTALL_PROGRAM} chpst runsv runsvchdir runsvdir sv svlogd \
		utmpset ${DESTDIR}${PREFIX}/sbin
	${INSTALL_SCRIPT} bin/svclone bin/svmod ${DESTDIR}${PREFIX}/bin
	@${MKDIR} ${DESTDIR}${PREFIX}/man/man7 ${DESTDIR}${PREFIX}/man/man8
	${INSTALL_MAN} docs/runit-faster.7 ${DESTDIR}${PREFIX}/man/man7
	${INSTALL_MAN} runit/man/*.8 docs/svclone.8 docs/svmod.8 ${DESTDIR}${PREFIX}/man/man8
	${INSTALL_MAN} runit/doc/*.html ${DESTDIR}${DOCSDIR}
	@${SED} -i '' -e 's,/usr/local/etc/runit,${RUNITDIR},g' \
		${DESTDIR}${PREFIX}/man/man8/*.8 \
		${DESTDIR}${DOCSDIR}/*.html
	@${SED} -i '' -e 's,%%RUNITDIR%%,${RUNITDIR},g' \
		-e 's,%%SBINDIR%%,${SBINDIR},g' \
		-e 's,%%SVDIR%%,${SVDIR},g' \
		-e 's,%%PREFIX%%,${PREFIX},g' \
		-e 's,%%LOCALBASE%%,${LOCALBASE},g' \
		${DESTDIR}${PREFIX}/bin/svclone \
		${DESTDIR}${PREFIX}/man/man7/runit-faster.7 \
		${DESTDIR}${PREFIX}/man/man8/svclone.8 \
		${DESTDIR}${PREFIX}/man/man8/svmod.8
	@${TAR} -C etc/runit --exclude .gitkeep -cf - . | ${TAR} -C ${DESTDIR}${RUNITDIR} -xf -
	@${TAR} -C etc/sv --exclude supervise -cf - . | ${TAR} -C ${DESTDIR}${SVDIR} -xf -
	@${FIND} ${DESTDIR}${RUNITDIR} -type f -exec ${SED} -i '' \
		-e 's,/usr/local/etc/runit,${RUNITDIR},g' \
		-e 's,//etc,/etc,' \
		-e 's,/usr/local,${LOCALBASE},g' {} \;
	@${FIND} ${DESTDIR}${SVDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${LOCALBASE}/,g' {} \;
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
		${LN} -sf /var/run/runit/supervise.$$(echo $${dir} | ${SED} "s,/,-,g") \
			$${dir}/supervise' \
		SUPERVISE {} \;
# Point runit to the run directory (a necessity to let runit work on
# read-only root filesystems) and make sure rebooting and powering off
# can work correctly.
	${LN} -s /var/run/runit/reboot ${DESTDIR}${RUNITDIR}/reboot
	${LN} -s /var/run/runit/stopit ${DESTDIR}${RUNITDIR}/stopit

format:
	${SHFMT} -w -s -p bin runit sv

manlint:
	${MANDOC} -Tlint docs/runit-faster.7 docs/svclone.8 docs/svmod.8
	${IGOR} docs/runit-faster.7 docs/svclone.8 docs/svmod.8

lint:
	${SHFMT} -d -s -p bin runit sv
	${SHFMT} -p -f bin runit sv | ${XARGS} ${SHELLCHECK} -s sh -x -e SC1091,SC2039

check:
	cd runit && package/check

archive:
	@tag=$$(${GIT} tag --contains HEAD); ver=$${tag#v*}; \
		${GIT} archive --format=tar \
			--prefix=freebsd-runit-$$ver/ \
			--output=freebsd-runit-$$ver.tar \
			$$tag && \
		${XZ_CMD} -f freebsd-runit-$$ver.tar

github-release: archive
	@${GIT} push --follow-tags github
	@tag=$$(${GIT} tag --contains HEAD); ver=$${tag#v*}; \
		${HUB} release create -p -a freebsd-runit-$$ver.tar.xz \
			-m "freebsd-runit-$$ver" $$tag

docs: docs/runit-faster.html docs/runit-faster.7.html

docs/runit-faster.html: docs/runit-faster.md
	${CMARK} docs/runit-faster.md > docs/runit-faster.html

docs/runit-faster.7.html: docs/runit-faster.7
	${MANDOC} -Thtml docs/runit-faster.7 | ${SED} \
	's,</style>,&<link rel="stylesheet" type="text/css" href="buttondown.css">,' \
	> docs/runit-faster.7.html

.PHONY: all archive check docs format github-release manlint lint
