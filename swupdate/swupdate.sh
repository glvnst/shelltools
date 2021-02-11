#!/bin/sh

main() {
  for cmd in update upgrade autoremove clean; do
    printf '==> %s\n' "$cmd"
    apt-get "$cmd" --assume-yes || exit 1
  done
}

[ -n "$IMPORT" ] || main "$@"
