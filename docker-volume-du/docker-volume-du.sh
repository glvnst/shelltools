#!/bin/sh

du_volumes() {
  for volume in $(docker volume ls -q); do
    set -- --volume="${volume}:/volumes/${volume}:ro" "$@"
  done

  docker run --rm --entrypoint /bin/sh --workdir /volumes "$@" busybox:latest '-c' 'du -hs *'
}

[ -n "$IMPORT" ] || du_volumes
