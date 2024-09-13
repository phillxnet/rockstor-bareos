# Rockstor Bareos server set
FROM opensuse/leap:15.6

LABEL maintainer="The Rockstor Project <https://rockstor.com>"
LABEL org.opencontainers.image.authors="The Rockstor Project <https://rockstor.com>"

# We only know if we are COMMUNIT or SUBSCRIPTION at run-time via env vars.
# so we install only known dependencies to speed-up deployment.
RUN zypper --non-interactive install wget  # to download bareos repo install script
# RUN zypper --non-interactive install postgresql-server  # Container-local Catalog DB
# 'bareos' metapackage dependencies outside of bareos repositories
RUN zypper --non-interactive install dbus-1 kbd kbd-legacy libapparmor1 libdbus-1-3 libip4tc2 \
    libjansson4 libjitterentropy3 libkmod2 liblzo2-2 libopenssl1_1 libpq5 libseccomp2 pam-config \
    pkg-config systemd systemd-default-settings systemd-default-settings-branding-openSUSE \
    systemd-presets-branding-MicroOS systemd-presets-common-SUSE

# config (all deamons):
VOLUME /etc/bareos
# data (Backups and service status):
VOLUME /var/lib/bareos
# Catalog/Postgres DB
# VOLUME /var/lib/postgresql/data

# We only host expose Director & Web-UI ports.
# 'Director' communications port.
EXPOSE 9101
# 'Client/File' daemon.
# EXPOSE 9102
# 'Storage' daemon.
# EXPOSE 9103
# "Web-UI".
EXPOSE 9100

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod u+x /docker-entrypoint.sh

# Postgresql (openSUSE default version):
# /usr/lib/systemd/system/postgresql.service

# BareOS services WorkingDirectory=/var/lib/bareos
# /etc/systemd/system/bareos-director.service \
# /etc/systemd/system/bareos-storage.service
# /etc/systemd/system/bareos-filedaemon.service

# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/usr/bin/sh", "-c", "/usr/sbin/bareos-dir;/usr/sbin/bareos-sd;/usr/sbin/bareos-fd"]
