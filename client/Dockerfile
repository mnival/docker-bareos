FROM debian:buster-20210927-slim
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
