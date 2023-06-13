FROM debian:stable-20230612-slim
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
