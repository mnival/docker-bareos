#!/bin/bash

/usr/lib/bareos/scripts/bareos-config deploy_config "/usr/lib/bareos/defaultconfigs" "/etc/bareos" "bareos-sd"

[ ! -d /var/lib/bareos/storage ] && mkdir -p /var/lib/bareos/storage
chown bareos:bareos /var/lib/bareos/ /var/lib/bareos/storage/
chmod 750 /var/lib/bareos/storage

# Run Dockerfile CMD
exec "$@"
