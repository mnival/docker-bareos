#!/bin/bash

set -e

# Default value
BAREOS_DB_NAME="${BAREOS_DB_NAME:-bareos}"
BAREOS_DB_USER="${BAREOS_DB_USER:-bareos}"
BAREOS_DB_PASSWORD="${BAREOS_DB_PASSWORD:-bareos}"
BAREOS_DB_HOST="${BAREOS_DB_HOST:-postgres}"
BAREOS_DB_PORT="${BAREOS_DB_PORT:-5432}"
BAREOS_CATALOG_NAME="${BAREOS_CATALOG_NAME:-MyCatalog}"
BAREOS_SD_HOST="${BAREOS_SD_HOST:-bareos-sd}"
BAREOS_FD_HOST="${BAREOS_FD_HOST:-bareos-fd}"

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-postgres}"

SMTP_SERVER="${SMTP_SERVER:-localhost}"

[ ! -d /etc/bareos/controls/ ] && mkdir /etc/bareos/controls/

if [ ! -f /etc/bareos/controls/bareos-dir ]; then
  printf "File /etc/bareos/controls/bareos-dir do not exist\n"
  # Init configuration
  if [ ! -d /etc/bareos/bareos-dir.d ]; then
	printf "Directory /etc/bareos/bareos-dir.d do not exist\nLaunch deploy_config bareos-dir\n"
    /usr/lib/bareos/scripts/bareos-config deploy_config "/usr/lib/bareos/defaultconfigs" "/etc/bareos" "bareos-dir"
  fi
  printf "Initialize database driver\n"
  /usr/lib/bareos/scripts/bareos-config initialize_database_driver
  # Configuration Catalog
  printf "Configuration Catalog\n"
  sed -i 's#dbpassword = ""#dbpassword = '\"${BAREOS_DB_PASSWORD}\"'#' /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  sed -i 's#dbname = "bareos"#dbname = '\"${BAREOS_DB_NAME}\"'\n  dbaddress = '\"${BAREOS_DB_HOST}\"'\n  dbport = '\"${BAREOS_DB_PORT}\"'#' /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf
  if [ "x${BAREOS_CATALOG_NAME}" != "xMyCatalog" ]; then
    /usr/lib/bareos/scripts/bareos-config replace MyCatalog ${BAREOS_CATALOG_NAME}
    mv /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf /etc/bareos/bareos-dir.d/catalog/${BAREOS_CATALOG_NAME}.conf
  fi
  printf "Update configuration\n"
  /usr/lib/bareos/scripts/bareos-config replace "bsmtp -h localhost" "bsmtp -h ${SMTP_SERVER}"
  sed -i 's#append = "/var/log/bareos/bareos.log" \(.*\)$#stdout \1#; s#append = "/var/log/bareos/bareos-audit.log"#stdout#' /etc/bareos/bareos-dir.d/messages/*.conf
  [ -f /etc/bareos/bareos-dir.d/storage/File.conf ] && sed -i 's?Address = .* \( *# .*\)$?Address = '\"${BAREOS_SD_HOST}\"'\1?' /etc/bareos/bareos-dir.d/storage/File.conf
  [ -f /etc/bareos/bareos-dir.d/client/bareos-fd.conf ] && sed -i 's?Address = .*?Address = '\"${BAREOS_FD_HOST}\"'?' /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  touch /etc/bareos/controls/bareos-dir
fi

if [ ! -f /etc/bareos/bconsole.conf ]; then
	printf "File /etc/bareos/bconsole.conf does not exist\nLaunch deploy_config bconsole\n"
	/usr/lib/bareos/scripts/bareos-config deploy_config "/usr/lib/bareos/defaultconfigs" "/etc/bareos" "bconsole"
fi

if egrep "XXX_REPLACE_WITH_ADMIN_PASSWORD_XXX" /etc/bareos/bareos-dir.d/console/admin.conf 2>/dev/null; then
  NEW_PASSWORD="$(openssl rand -base64 20)"
  /usr/lib/bareos/scripts/bareos-config replace "XXX_REPLACE_WITH_ADMIN_PASSWORD_XXX" "${NEW_PASSWORD}"
  echo "admin password is ${NEW_PASSWORD}"
fi

export PGUSER=${POSTGRES_USER}
export PGHOST=${BAREOS_DB_HOST}
export PGPASSWORD=${POSTGRES_PASSWORD}

max_retries=10
try=0
until pg_isready > /dev/null 2>&1 || [ "$try" -gt "$max_retries" ]; do
  echo "wait database..."
  try=$((try+1))
  sleep 10s
done
if [ "$try" -gt "$max_retries" ]; then
  echo "Database not available!"
fi

if [ ! -f /etc/bareos/controls/bareos-db ]; then
  printf "File /etc/bareos/controls/bareos-db does not exist\nLaunch init database\n"
  # Init database
  /usr/lib/bareos/scripts/create_bareos_database
  /usr/lib/bareos/scripts/make_bareos_tables
  /usr/lib/bareos/scripts/grant_bareos_privileges
  touch /etc/bareos/controls/bareos-db
else
  DB_VERSION=$(/usr/lib/bareos/scripts/bareos-config get_database_version)
  DB_CURRENT_VERSION=$(psql -qtAX -d bareos -c "select versionid from version")
  if [ ${DB_CURRENT_VERSION} -lt ${DB_VERSION} ]; then
    printf "Update database to ${DB_VERSION}\n"
    /usr/lib/bareos/scripts/update_bareos_tables
    /usr/lib/bareos/scripts/grant_bareos_privileges
  fi
fi

# Remove variable
unset PGPASSWORD PGHOST PGUSER POSTGRES_PASSWORD POSTGRES_USER BAREOS_CATALOG_NAME BAREOS_DB_PORT BAREOS_DB_HOST BAREOS_DB_PASSWORD BAREOS_DB_USER BAREOS_DB_NAME

chown bareos:bareos /var/lib/bareos /etc/bareos/.rndpwd

# Run CMD
exec "$@"

# vim: ts=2 sts=2 sw=2 expandtab
