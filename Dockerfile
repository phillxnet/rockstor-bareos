# Rockstor Bareos server set
FROM opensuse/leap:15.6

LABEL maintainer="The Rockstor Project <https://rockstor.com>"
LABEL org.opencontainers.image.authors="The Rockstor Project <https://rockstor.com>"

# zypper in all bareos package dependencies to speed-up final install
# as we only know if we are COMMUNIT OR SUBSCRIPTION at run-time via env vars.

# config (all deamons):
VOLUME /etc/bareos
# data (Backups and service status):
VOLUME /var/lib/bareos
# Catalog/Postgres DB
VOLUME /var/lib/postgresql/data

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


# ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["/usr/sbin/bareos-dir", "-u", "bareos", "-f"]
