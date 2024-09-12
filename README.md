# Rockstor BareOS server set container

Follows BareOS's own install instructions as closely as possible: given container limitations.
Initially uses only BareOS compiled community packages [Bareos Community Repository](https://download.bareos.org/current) `Current` variant.
Intended capability, upon instantiation, is to use the [Official Bareos Subscription Repository](https://download.bareos.com/bareos/release/),
if non-empty subscription credentials are passed by environmental variables.

See: [Decide about the Bareos release to use](https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#decide-about-the-bareos-release-to-use)

Based on opensuse/leap:15.6 as per BareOS instructions:
[SUSE Linux Enterprise Server (SLES), openSUSE](https://docs.bareos.org/IntroductionAndTutorial/InstallingBareos.html#install-on-suse-based-linux-distributions)

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
