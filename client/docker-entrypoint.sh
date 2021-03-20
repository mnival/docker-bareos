#!/bin/bash

if [ ! -d /etc/bareos/bareos-fd.d ]; then
	/usr/lib/bareos/scripts/bareos-config deploy_config "/usr/lib/bareos/defaultconfigs" "/etc/bareos" "bareos-fd"
fi

chown bareos:bareos /var/lib/bareos

# Run Dockerfile CMD
exec "$@"
