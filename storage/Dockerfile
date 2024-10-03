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
		bareos-storage \
		bareos-storage-droplet \
    netcat-traditional \
	; \
	rm -rf /var/lib/apt/lists/* /etc/bareos/* /etc/bareos/.rndpwd

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

EXPOSE 9103

VOLUME /etc/bareos
VOLUME /var/lib/bareos

HEALTHCHECK --interval=1m --start-period=1m --timeout=3s --retries=3 \
  CMD netcat -vz 127.0.0.1 9103 || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/bareos-sd", "-u", "bareos", "-f"]
