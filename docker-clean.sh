#!/bin/sh

# used as a variable to get around gnu behavior
XARGS="xargs"

# the use of these variables helps testing and debugging
DOCKER_QUERY="docker"
DOCKER_MUTATE="docker"

prefix() {
  sed "s/^/${1}: /g"
}

clean_containers() {
  # docker container prune --force
  $DOCKER_QUERY container ls \
    --quiet \
    --all \
    --filter status=exited \
    --filter status=created \
  | $XARGS \
    $DOCKER_MUTATE container rm --volumes --
}

clean_images() {
  # docker image prune --all --filter until=2160h --force 
  $DOCKER_QUERY image ls \
    --quiet \
    --filter dangling=true \
  | $XARGS \
    $DOCKER_MUTATE image rm --
}

clean_networks() {
  $DOCKER_MUTATE network prune \
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
  # adjust for gnu xargs behavior
  if sh -c 'true | xargs --no-run-if-empty >/dev/null 2>&1'; then
    XARGS="xargs --no-run-if-empty"
  fi

  for component in container image network volume do
  done
  clean_containers | prefix container
  clean_images | prefix image
  clean_networks | prefix network
  clean_volumes | prefix volume
}

[ -n "$IMPORT" ] || main "$@"
