#!/bin/sh
# swupdate: run a typical software update commands on a debian-based linux system
SELF="$(basename "$0" ".sh")"

usage() {
  exception="$1"
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [arg [...]]" \
    "" \
    "-h / --help        show this message" \
    "-d / --debug       print additional debugging messages" \
    "-y / --assume-yes  tell the apt-get system to proceed without prompting" \
    "" \
    "runs a typical software update commands on a debian-based linux system" \
    "this includes the following apt-get subcommands:" \
    " * update" \
    " * upgrade" \
    " * autoremove" \
    " * clean" \
    "" # no trailing slash

  [ -n "$exception" ] && exit 1
  exit 0
}

warn() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

main() {
  assume_yes=""

  # arg-processing loop
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop; if you break in the loop don't forget to shift first
    case "$arg" in
      -h|-help|--help)
        usage
        ;;

      -d|--debug)
        set -x
        ;;

      --mega-turtles)
        usage "You can't handle MEGA-TURTLES."
        ;;

      -y|--assume-yes)
        assume_yes="--assume-yes"
        ;;

      --)
        shift || true
        break
        ;;

      *)
        # unknown arg, leave it back in the positional params
        break
        ;;
    esac
    shift || break
  done

  # ensure required environment variables are set
  # : "${USER:?the USER environment variable must be set}"

  for cmd in update upgrade autoremove clean; do
    printf '==> %s\n' "$cmd"
    apt-get "$cmd" $assume_yes || exit
  done

  exit 0
}

[ -n "$IMPORT" ] || main "$@"; exit

