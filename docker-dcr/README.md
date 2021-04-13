# dcr

"docker compose restart" - a utility for restarting services in a docker-compose container composition

I've had a function or script called `dcr` since I started using docker-compose (not long after it was renamed from `fig`). In the earlier days of docker-compose, things were a bit less stable than they are today and I needed a script for restarting services in compose files that could handle certain docker failures and work around some known bugs. In the context of my team at the time it was helpful to have a standardized process (including error recovery) and an easy shorthand.

Most of what this script does can be accomplished with the following now-available docker-compose commands:

```sh
dcr() {
  ( # a strict, verbose subshell
    set -ex
    docker-compose rm --force --stop -v "$@" \
    docker-compose up -d --remove-orphans --renew-anon-volumes "$@"
  )
}
```

Nevertheless, I continue to use this script.

## dcr vs dcpr

If the program is called with the name `dcpr`, it adds a "docker-compose pull" step to its operation.

I install `dcr` normally in my bin directory and make a symlink called `dcpr` which points to it -- for example by running the output of the following command:

```sh
echo ln -s "$(which dcr)" "$(dirname "$(which dcr)")/dcpr"
```

## usage

This is the information the program prints when run with the `--help` argument:

### dcr

```
Usage: dcr [-h|--help] [compose_service [...]]

-h / --help              show this message
--pull                   pull images before the restart process
--debug                  internally enable shell 'set -x' debug output
compose_service          optional names of services to restart

This utility restarts docker-compose services.
By default all services in the project directory will be restarted.

Unrecognized arguments will end argument processing; they are passed to docker-compose
```

### dcpr

```
Usage: dcpr [-h|--help] [compose_service [...]]

-h / --help              show this message
--pull                   pull images before the restart process
--debug                  internally enable shell 'set -x' debug output
compose_service          optional names of services to restart

This utility pulls the images for docker-compose services then restarts them.
By default all services in the project directory will be restarted.

Unrecognized arguments will end argument processing; they are passed to docker-compose
```
