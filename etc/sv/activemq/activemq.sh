#!/bin/sh
[ -r conf ] && . ./conf
: "${JAVA:=/usr/local/bin/java}"
install -d -m 0750 -o activemq -g activemq /var/log/activemq
install -d -m 0750 -o activemq -g activemq /var/db/activemq
exec >/dev/null 2>&1
# shellcheck disable=SC2086
chpst -u activemq:activemq -P \
	${JAVA} -server \
	-Xmx512M \
	-Dorg.apache.activemq.UseDedicatedTaskRunner=true \
	-Djava.util.logging.config.file=logging.properties \
	-Dcom.sun.management.jmxremote \
	${JAVAFLAGS} \
	-Dactivemq.classpath=/usr/local/etc/activemq \
	-Dactivemq.conf=/usr/local/etc/activemq \
	-Dactivemq.data=/var/db/activemq \
	-Dactivemq.logs=/var/log/activemq \
	-Dactivemq.home=/usr/local/share/activemq \
	-Dactivemq.base=/usr/local/share/activemq \
	-Dactivemq.hostname="$(hostname)" \
	-jar /usr/local/share/activemq/bin/activemq.jar \
	"$@"
