FROM debian:stable-20240926-slim
LABEL maintainer "Michael Nival <docker@mn-home.fr>"

ENV DEBIAN_FRONTEND noninteractive

ENV BAREOS_REPO https://download.bareos.org/current/Debian_12/
ENV BAREOS_KEY ${BAREOS_REPO}/Release.key

RUN set -ex; \
  addgroup -q --gid 120 --system bareos; \
  adduser -q --system --ingroup bareos --home /var/lib/bareos --no-create-home --gecos "bareos" --uid 120 bareos; \
  \
  apt update; \
  apt full-upgrade -y; \
  \
  apt install -y --no-install-recommends curl ca-certificates; \
  curl -s --fail ${BAREOS_KEY} -o /etc/apt/trusted.gpg.d/bareos-keyring.asc; \
  apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false curl; \
  printf "deb ${BAREOS_REPO} /\n" > /etc/apt/sources.list.d/bareos.list; \
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
