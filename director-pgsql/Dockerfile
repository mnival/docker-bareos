FROM debian:stable-slim
LABEL maintainer "Michael Nival <docker@mn-home.fr>"

ENV DEBIAN_FRONTEND noninteractive

ENV BAREOS_RELEASE=20
ENV BAREOS_REPO http://download.bareos.org/bareos/release/${BAREOS_RELEASE}/Debian_10
ENV BAREOS_KEY ${BAREOS_REPO}/Release.key
ENV BAREOS_DPKG_CONF bareos-database-common bareos-database-common

RUN set -ex; \
	apt update; \
	apt full-upgrade -y; \
	\
	apt install -y --no-install-recommends gnupg; \
	apt-key --keyring /etc/apt/trusted.gpg.d/bareos-keyring.gpg adv --fetch-keys ${BAREOS_KEY}; \
	apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false gnupg; \
	printf "deb ${BAREOS_REPO} /\n" > /etc/apt/sources.list.d/bareos.list; \
	apt update; \
	\
	printf "${BAREOS_DPKG_CONF}/dbconfig-install boolean false\n" | debconf-set-selections; \
	printf "${BAREOS_DPKG_CONF}/install-error select ignore\n" | debconf-set-selections; \
	printf "${BAREOS_DPKG_CONF}/database-type select pgsql\n" | debconf-set-selections; \
	printf "${BAREOS_DPKG_CONF}/missing-db-package-error select ignore\n" | debconf-set-selections; \
	\
	apt -y install --no-install-recommends \
		bareos-director \
		postgresql-client \
		msmtp-mta \
	; \
	chmod 750 /var/lib/bareos/storage/; \
	chown bareos:bareos /var/lib/bareos/storage/; \
	rm -rf /var/lib/apt/lists/* /etc/bareos/* /etc/bareos/.rndpwd

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9101

VOLUME /etc/bareos
VOLUME /var/lib/bareos

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
