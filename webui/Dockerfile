FROM debian:stable-20240513-slim⁠
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
  apt -y install --no-install-recommends \
    bareos-webui \
  ; \
  sed -i 's#Alias /bareos-webui#Alias /#; s#RewriteBase /bareos-webui#RewriteBase /#; s#public#public/#g' /etc/apache2/conf-available/bareos-webui.conf; \
  rm /var/log/apache2/access.log /var/log/apache2/error.log /var/log/apache2/other_vhosts_access.log; \
  ln -s /dev/stdout /var/log/apache2/access.log; \
  ln -s /dev/stdout /var/log/apache2/other_vhosts_access.log; \
  ln -s /dev/stderr /var/log/apache2/error.log; \
  \
  rm -rf /var/lib/apt/lists/* /etc/bareos

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

RUN tar czf /bareos-webui.tgz /etc/bareos-webui

EXPOSE 80

VOLUME /etc/bareos-webui

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
