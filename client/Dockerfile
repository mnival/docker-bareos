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
	apt -y install --no-install-recommends \
		bareos-client \
	; \
	chmod 750 /var/lib/bareos/storage/; \
	chown bareos:bareos /var/lib/bareos/storage/; \
	rm -rf /var/lib/apt/lists/* /etc/bareos/* /etc/bareos/.rndpwd

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9102

VOLUME /etc/bareos
VOLUME /var/lib/bareos/storage

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-fd", "-u", "bareos", "-f"]
