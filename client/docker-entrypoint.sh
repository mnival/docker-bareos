#!/bin/bash

/usr/lib/bareos/scripts/bareos-config deploy_config "/usr/lib/bareos/defaultconfigs" "/etc/bareos" "bareos-fd"

chown bareos:bareos /var/lib/bareos

# Run Dockerfile CMD
exec "$@"
