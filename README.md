# Rockstor BareOS server set container

Follows BareOS's own install instructions as closely as possible: given container limitations.
Initially uses only BareOS compiled community packages [Bareos Community Repository](https://download.bareos.org/current) `Current` variant.
Intended capability, upon instantiation, is to use the [Official Bareos Subscription Repository](https://download.bareos.com/bareos/release/),
if non-empty subscription credentials are passed by environmental variables.

See: [Decide about the Bareos release to use](https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#decide-about-the-bareos-release-to-use)

Based on opensuse/leap:15.6 as per BareOS instructions:
[SUSE Linux Enterprise Server (SLES), openSUSE](https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#install-on-suse-based-linux-distributions)

Inspired & informed by the many years of BareOS container maintenance done by Marc Benslahdine https://github.com/barcus/bareos, and contributors.
Here we take a monolithic approach, where-as Marc's docker image definitions are quite the opposite.

## Environmental Variables

### Remote Catalog (Postgres DB container)
https://hub.docker.com/_/postgres

**Admin credentials for DB init**
(var baros - var postgres)
- DB_ADMIN_USER = 'postgres' (default) admin user in postgres container
- DB_ADMIN_PASSWORD = POSTGRES_PASSWORD (from postgres image)

**Remote DB authentication via .pgpass file** 
- DB_HOST: postgres container name (bareos-db)
- DB_PORT: port (default 5432) of DB_HOST
- DB_NAME: bareos database name (bareos)
- DB_USER: bareos database user (bareos)
- DB_PASSWORD: DB_USER password for DB_NAME database access

## Local Build
- -t tag <name>
- . indicates from-current directory

```
docker build -t bareos-server-set .
```

## Local Run

```
docker run --name bareos-server-set
```

## Interactive shell

```
docker exec -it bareos-server-set sh
```

## BareOS rpm package scriptlet actions

### bareos-common
```shell
Info: replacing 'XXX_REPLACE_WITH_STORAGE_PASSWORD_XXX' in /etc/bareos/bareos-sd.d/director/bareos-dir.conf
Info: replacing 'XXX_REPLACE_WITH_STORAGE_MONITOR_PASSWORD_XXX' in /etc/bareos/bareos-sd.d/director/bareos-mon.conf
Info: replacing 'XXX_REPLACE_WITH_STORAGE_MONITOR_PASSWORD_XXX' in /etc/bareos/tray-monitor.d/storage/StorageDaemon-local.conf
```

### bareos-storage
```shell
Info: replacing 'XXX_REPLACE_WITH_LOCAL_HOSTNAME_XXX' with '86bf077fd97b' in /etc/bareos/bareos-fd.d/client/myself.conf
Info: replacing 'XXX_REPLACE_WITH_CLIENT_PASSWORD_XXX' in /etc/bareos/bareos-fd.d/director/bareos-dir.conf
Info: replacing 'XXX_REPLACE_WITH_CLIENT_MONITOR_PASSWORD_XXX' in /etc/bareos/bareos-fd.d/director/bareos-mon.conf
Info: replacing 'XXX_REPLACE_WITH_CLIENT_MONITOR_PASSWORD_XXX' in /etc/bareos/tray-monitor.d/client/FileDaemon-local.conf
```

### bareos-database-postgresql
```shell
Info: replacing 'XXX_REPLACE_WITH_DIRECTOR_PASSWORD_XXX' in /etc/bareos/bconsole.conf
```

### bareos-client
```shell
Info: replacing 'XXX_REPLACE_WITH_LOCAL_HOSTNAME_XXX' with '86bf077fd97b' in /etc/bareos/bareos-dir.d/storage/File.conf
Info: replacing 'XXX_REPLACE_WITH_DIRECTOR_PASSWORD_XXX' in /etc/bareos/bareos-dir.d/director/bareos-dir.conf
Info: replacing 'XXX_REPLACE_WITH_CLIENT_PASSWORD_XXX' in /etc/bareos/bareos-dir.d/client/bareos-fd.conf
Info: replacing 'XXX_REPLACE_WITH_STORAGE_PASSWORD_XXX' in /etc/bareos/bareos-dir.d/storage/File.conf
Info: replacing 'XXX_REPLACE_WITH_DIRECTOR_MONITOR_PASSWORD_XXX' in /etc/bareos/bareos-dir.d/console/bareos-mon.conf
```

