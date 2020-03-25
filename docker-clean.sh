#!/bin/sh

# used as a variable to get around gnu behavior
XARGS="xargs"

# the use of these variables helps testing and debugging
DOCKER_QUERY="docker"
DOCKER_MUTATE="docker"

usage() {
  self="$(basename "$0")"

  printf '%s\n' \
    "Usage: $self [-h | --help]" \
    "" \
    "This script removes bits of docker detritus, including:" \
    "" \
    "* Stopped containers older than 4 hours" \
    "* Dangling images" \
    "* Other images older than 90 days" \
    "* Unused networks older than 7 days" \
    "* Dangling volumes with 32-character hexadecimal names (anonymous volumes)" \
    ""

  exit 1
}

clean_containers() {
  $DOCKER_MUTATE container prune \
    --filter 'until=4h' \
    --force
}

clean_images() {
  $DOCKER_MUTATE image prune \
    --force
  $DOCKER_MUTATE image prune \
    --all \
    --filter "until=2160h" \
    --force
}

clean_networks() {
  $DOCKER_MUTATE network prune \
    --filter "until=168h" \
    --force
}

clean_volumes() {
  # posix-compliance, in this case dealing with the lack of POSIX sed's regex
  # numeric quantifiers, is THE HILL I AM GOING TO DIE ON!
  # '/^[0-9a-f]{32}$/' ... would that it were so simple
  $DOCKER_QUERY volume ls \
    --quiet \
    --filter dangling=true \
  | sed -n '/^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$/p' \
  | $XARGS \
    $DOCKER_MUTATE volume rm --
}

main() {
  [ -z "$*" ] || usage

  # adjust for gnu xargs behavior
  if sh -c 'true | xargs --no-run-if-empty >/dev/null 2>&1'; then
    XARGS="xargs --no-run-if-empty"
  fi

  for component in container image network volume; do
    "clean_${component}s" | sed "s/^/${component}: /g"
  done
}

[ -n "$IMPORT" ] || main "$@"
