#!/bin/bash

if [ ! -f /etc/bareos-webui/directors.ini ]; then
  tar xzf /bareos-webui.tgz
fi

# Run Dockerfile CMD
exec "$@"
