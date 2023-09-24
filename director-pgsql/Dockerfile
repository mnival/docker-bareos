FROM debian:stable-20230919-slim
LABEL maintainer "Michael Nival <docker@mn-home.fr>"

ENV DEBIAN_FRONTEND noninteractive

ENV BAREOS_RELEASE=21
ENV BAREOS_REPO http://download.bareos.org/bareos/release/${BAREOS_RELEASE}/Debian_11
ENV BAREOS_KEY ${BAREOS_REPO}/Release.key

RUN set -ex; \
	addgroup -q --gid 120 --system bareos; \
	adduser -q --system --ingroup bareos --home /var/lib/bareos --no-create-home --gecos "bareos" --uid 120 bareos; \
	\
	apt update; \
	apt full-upgrade -y; \
	\
	apt install -y --no-install-recommends gnupg; \
	apt-key --keyring /etc/apt/trusted.gpg.d/bareos-keyring.gpg adv --fetch-keys ${BAREOS_KEY}; \
	apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false gnupg; \
	printf "deb ${BAREOS_REPO} /\n" > /etc/apt/sources.list.d/bareos.list; \
  printf "deb http://deb.debian.org/debian buster main\ndeb http://security.debian.org/debian-security buster/updates main\ndeb http://deb.debian.org/debian buster-updates main\n" > /etc/apt/sources.list.d/buster.list; \
	apt update; \
	\
  export BAREOS_DPKG_CONF="bareos-database-common bareos-database-common"; \
  printf "${BAREOS_DPKG_CONF}/dbconfig-install boolean false\n" | debconf-set-selections; \
  printf "${BAREOS_DPKG_CONF}/install-error select ignore\n" | debconf-set-selections; \
  printf "${BAREOS_DPKG_CONF}/database-type select pgsql\n" | debconf-set-selections; \
  printf "${BAREOS_DPKG_CONF}/missing-db-package-error select ignore\n" | debconf-set-selections; \
  \
  apt -y install --no-install-recommends \
    bareos-director \
    bareos-bconsole \
    postgresql-client \
    msmtp-mta \
  ; \
  chmod 750 /var/lib/bareos/storage/; \
  chown bareos:bareos /var/lib/bareos/storage/; \
  rm -rf /var/lib/apt/lists/* /etc/bareos/* /etc/bareos/.rndpwd

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./config/webui-admin.conf /usr/lib/bareos/defaultconfigs/bareos-dir.d/profile/
COPY ./config/admin.conf /usr/lib/bareos/defaultconfigs/bareos-dir.d/console/

RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9101

VOLUME /etc/bareos
VOLUME /var/lib/bareos

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
