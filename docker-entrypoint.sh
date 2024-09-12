#!/usr/bin/sh

# https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#install-on-suse-based-linux-distributions
# https://docs.bareos.org/IntroductionAndTutorial/WhatIsBareos.html#bareos-binary-release-policy

# ADD REPOS (COMMUNIT OR SUBSCRIPTION)
# Later pick according to variables entered at Rock-on
# - empty = community
# - BareOS subscription credentials = Subscription repository

# Official Bareos Subscription Repository
# - https://download.bareos.com/bareos/release/
# User + Pass entered in the following retrieves the script pre-edited:
# wget https://download.bareos.com/bareos/release/23/SUSE_15/add_bareos_repositories.sh
# or
# wget https://download.bareos.com/bareos/release/23/SUSE_15/add_bareos_repositories_template.sh
# sed edit with BareOS subscription credentials and execute it.

# Community current: https://download.bareos.org/current
# - wget https://download.bareos.org/current/SUSE_15/add_bareos_repositories.sh


if [ ! -f /etc/bareos/bareos-config.control ]; then

  wget https://download.bareos.org/current/SUSE_15/add_bareos_repositories.sh
  sh ./add_bareos_repositories.sh

  # Director & Storage daemon packages
  zypper install bareos
  # Director local Client/file daemon: https://docs.bareos.org/IntroductionAndTutorial/InstallingBareosClient.html
  zypper install bareos-bconsole bareos-filedaemon
  # Web-UI https://docs.bareos.org/IntroductionAndTutorial/BareosWebui.html (defaults to using Apache)
  zypper install bareos-webui


  # 'Storage' daemon
  ## Director config
  sed -i 's#Address = .*#Address = '\""${BAREOS_SD_HOST}"\"'#' \
    /etc/bareos/bareos-dir.d/storage/File.conf
  sed -i 's#Password = .*#Password = '\""${BAREOS_SD_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/storage/File.conf
  ## Daemon config
  bareos_sd_config="/etc/bareos/bareos-sd.d/director/bareos-dir.conf"
  sed -i 's#Password = .*#Password = '\""${BAREOS_SD_PASSWORD}"\"'#' $bareos_sd_config

  # 'Client/file' daemon
  ## Director config
  sed -i 's#Address = .*#Address = '\""${BAREOS_FD_HOST}"\"'#' \
    /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  sed -i 's#Password = .*#Password = '\""${BAREOS_FD_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/client/bareos-fd.conf
  ## Daemon config
  bareos_fd_config="/etc/bareos/bareos-fd.d/director/bareos-dir.conf"
  sed -i 's#Password = .*#Password = '\""${BAREOS_FD_PASSWORD}"\"'#' $bareos_fd_config

  # WebUI
  ## Director config
  sed -i 's#Password = .*#Password = '\""${BAREOS_WEBUI_PASSWORD}"\"'#' \
    /etc/bareos/bareos-dir.d/console/admin.conf
  ## WebUI config: defaults to localhost for director
  # sed -i "s/diraddress = \"localhost\"/diraddress = \"${BAREOS_DIR_HOST}\"/" /etc/bareos-webui/directors.ini

  # MyCatalog Backup
  ## Fileset
  sed -i "s#/var/lib/bareos/bareos.sql#/var/lib/bareos-director/bareos.sql#" \
    /etc/bareos/bareos-dir.d/fileset/Catalog.conf
  ## Job
  sed -i "s#make_catalog_backup MyCatalog#make_catalog_backup MyCatalog#" \
    /etc/bareos/bareos-dir.d/job/BackupCatalog.conf

  # Control file
  touch /etc/bareos/bareos-config.control
fi


[[ -z "${DB_INIT}" ]] && DB_INIT='false'
[[ -z "${DB_UPDATE}" ]] && DB_UPDATE='false'

# https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#other-platforms
if [ ! -f /etc/bareos/bareos-db.control ] && [ "${DB_INIT}" == 'true' ] ; then
  # Init BareOS Postgres DB using default 'postgres' administrationuser:
  echo "Bareos Catalog/DB init"
  su postgres -c /usr/lib/bareos/scripts/create_bareos_database 2>/dev/null
  su postgres -c /usr/lib/bareos/scripts/make_bareos_tables 2>/dev/null
  su postgres -c /usr/lib/bareos/scripts/grant_bareos_privileges 2>/dev/null
  touch /etc/bareos/bareos-db.control
fi

if [ "${DB_UPDATE}" == 'true' ] ; then
  # Try Postgres upgrade
  echo "Bareoos DB update"
  echo "Bareoos DB update: Update tables"
  /etc/bareos/scripts/update_bareos_tables  2>/dev/null
  echo "Bareoos DB update: Grant privileges"
  /etc/bareos/scripts/grant_bareos_privileges  2>/dev/null
fi

# Fix permissions
# find /etc/bareos ! -user bareos -exec chown bareos {} \;
# chown -R bareos:bareos /var/lib/bareos /var/log/bareos

systemctl start bareos-director
systemctl start bareos-storage
systemctl start bareos-filedaemon

# Run Dockerfile CMD
exec "$@"
