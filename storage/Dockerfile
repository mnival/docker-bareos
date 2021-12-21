FROM debian:stable-20211220-slim
LABEL maintainer "Michael Nival <docker@mn-home.fr>"

ENV DEBIAN_FRONTEND noninteractive

ENV BAREOS_RELEASE=20
ENV BAREOS_REPO http://download.bareos.org/bareos/release/${BAREOS_RELEASE}/Debian_10
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
	apt -y install --no-install-recommends \
		bareos-storage \
		bareos-storage-droplet \
    netcat \
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
