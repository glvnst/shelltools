#!/bin/sh
# backup2usb: runs a restic backup of some default paths
SELF="$(basename "$0" ".sh")"


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

eject_usb() {
  disk_path="${RESTIC_REPOSITORY%"${RESTIC_REPOSITORY#/Volumes/*/*}"}"
  warn "ejecting ${disk_path}"
  diskutil eject "${disk_path}"
}

warn() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

main() {
  eject="1" # eject by default
  init="" # backup (not init) by default

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
        init="1"
        ;;

      --no-eject)
        eject=""
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

  # add the default backup items to the positional params
  set -- \
    ~/Desktop \
    ~/Documents \
    ~/Downloads \
    ~/bin \
    ~/work \
    "$@" \
  ;

  # source the local config file (it can manipulate the positional params to
  # change the backup items and arguments)
  config_file="$HOME/.backup2usb_config.sh"
  # shellcheck source=/dev/null
  [ -f "$config_file" ] && . "$config_file"

  export \
    RESTIC_REPOSITORY="${BACKUP2USB_REPOSITORY:-/Volumes/backup/backup2usb}" \
    RESTIC_PASSWORD_COMMAND="${BACKUP2USB_PASSWORD_COMMAND:-keychain-password get backup2usb}" \
  ;

  # init is a one-off process to create the repo
  [ -n "$init" ] && exec restic --verbose init

  # invoke restic
  backup "$@" || die "restic failed"

  # eject the volume the restic archive is located on
  [ -n "$eject" ] && eject_usb

  exit 0
}

main "$@"; exit
