FIND?=		find
GIT?=		git
GZIP_CMD?=	gzip
MKDIR?=		mkdir -p
SED?=		sed
TAR?=		tar

PREFIX?=	/usr/local
RUNITDIR?=	${DESTDIR}${PREFIX}/etc/runit
SVDIR?=		${DESTDIR}${PREFIX}/etc/sv
SVLOCALDIR?=	${DESTDIR}${PREFIX}/etc/sv-local

install:
	@${MKDIR} ${RUNITDIR} ${SVDIR} ${SVLOCALDIR}
	@${TAR} -C runit --exclude .gitkeep -cf - . | ${TAR} -C ${RUNITDIR} -xf -
	@${TAR} -C sv -cf - . | ${TAR} -C ${SVDIR} -xf -
	@${FIND} ${RUNITDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${PREFIX}/,g' {} \;
	@${FIND} ${SVDIR} -type f -exec ${SED} -i '' -e 's,/usr/local/,${PREFIX}/,g' {} \;

archive:
	@tag=$$(${GIT} tag); ver=$${tag#v*}; \
		${GIT} archive --format=tar \
			--prefix=freebsd-runit-$$ver/ \
			--output=freebsd-runit-$$ver.tar \
			$$tag && \
		${GZIP_CMD} freebsd-runit-$$ver.tar
