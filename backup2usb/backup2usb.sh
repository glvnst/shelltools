#!/bin/sh
# backup2usb: runs a restic backup of some default paths
SELF="$(basename "$0" ".sh")"

export \
  RESTIC_REPOSITORY="${BACKUP2USB_REPOSITORY:-/Volumes/backup/backup2usb}" \
  RESTIC_PASSWORD_COMMAND="${BACKUP2USB_PASSWORD_COMMAND:-keychain-password get backup2usb}" \
  ;

usage() {
  exception="$1"; shift
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [path [...]]" \
    "" \
    "-h / --help   show this message" \
    "-d / --debug  print additional debugging messages" \
    "path          additional paths to backup" \
    "" \
    "Runs a restic backup of some default paths and any additional paths" \
    "" # no trailing slash

  [ -n "$exception" ] && exit 1
  exit 0
}

backup() {
  restic \
    --verbose \
    --cleanup-cache \
    --exclude '.DS_Store' \
    --exclude '.cache' \
    --exclude '.kube' \
    --exclude '.node-gyp' \
    --exclude '.npm' \
    --exclude '.pyenv' \
    --exclude '.pylint.d' \
    --exclude '.venv' \
    --exclude 'Caches' \
    --exclude 'node_modules' \
    --exclude 'site-packages' \
    --exclude 'vendor' \
    --exclude 'venv' \
    backup \
    "$@"
}

warn() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

main() {
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

      --init)
        exec restic --verbose init
        ;;

      --mega-turtles)
        usage "You can't handle MEGA TURTLES."
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

  # do things
  backup \
    "$HOME/Desktop" \
    "$HOME/Documents" \
    "$HOME/Downloads" \
    "$HOME/bin" \
    "$HOME/work" \
  ;

  exit 0
}

[ -n "$IMPORT" ] || main "$@"; exit
