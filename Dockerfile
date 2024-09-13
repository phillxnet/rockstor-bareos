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

# bareos-webui package dependencies ouside of bareos repositories approx 90MB installed
RUN zypper --non-interactive install apache2 apache2-prefork fontconfig libX11-6 libX11-data \
    libXau6 libXpm4 libapr-util1 libapr1 libargon2-1 libbrotlienc1 libfontconfig1 libfreetype6 \
    libgd3 libgdbm4 libgnutls30 libhogweed6 libicu73_2 libicu73_2-ledata libjbig2 libjpeg8 libnettle8 \
    libonig4 libpng16-16 libtiff5 libwebp7 libxcb1 libzip5 logrotate php8 php8-bz2 php8-ctype php8-curl \
    php8-dom php8-fileinfo php8-fpm php8-gd php8-gettext php8-iconv php8-intl php8-mbstring php8-openssl \
    php8-xmlreader php8-xmlwriter php8-zip system-user-wwwrun xz

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

# BareOS Web-UI
# /usr/lib/systemd/system/apache2.service

# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/usr/bin/sh", "-c", "/usr/sbin/bareos-dir;/usr/sbin/bareos-sd;/usr/sbin/bareos-fd"]
