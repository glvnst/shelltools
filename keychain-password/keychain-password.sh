#!/bin/sh
# keychain-password: utility for getting/setting keychain password items
SELF="$(basename "$0" ".sh")"

usage() {
  exception="$1"; shift
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] (get|set) KEYID" \
    "" \
    "-h / --help   show this message" \
    "-d / --debug  print additional debugging messages" \
    "" \
    "get KEYID     get the password item with the given KEYID" \
    "set KEYID     set the password item with the given KEYID" \
    "" \
    "This utility for getting and setting passwords in the system keychain" \
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

password_get() {
  keyid="${1:?password_get requires a keyid argument}"
  # Usage: find-generic-password [-a account] [-s service] [options...] [-g] [keychain...]
  #     -a  Match "account" string
  #     -c  Match "creator" (four-character code)
  #     -C  Match "type" (four-character code)
  #     -D  Match "kind" string
  #     -G  Match "value" string (generic attribute)
  #     -j  Match "comment" string
  #     -l  Match "label" string
  #     -s  Match "service" string
  #     -g  Display the password for the item found
  #     -w  Display only the password on stdout
  # If no keychains are specified to search, the default search list is used.
  #         Find a generic password item.
  exec /usr/bin/security find-generic-password \
    -s "be.backplane.keychain-password" \
    -a "${keyid}" \
    -w
}

password_set() {
  keyid="${1:?password_get requires a keyid argument}"
  # Usage: add-generic-password [-a account] [-s service] [-w password] [options...] [-A|-T appPath] [keychain]
  #     -a  Specify account name (required)
  #     -c  Specify item creator (optional four-character code)
  #     -C  Specify item type (optional four-character code)
  #     -D  Specify kind (default is "application password")
  #     -G  Specify generic attribute (optional)
  #     -j  Specify comment string (optional)
  #     -l  Specify label (if omitted, service name is used as default label)
  #     -s  Specify service name (required)
  #     -p  Specify password to be added (legacy option, equivalent to -w)
  #     -w  Specify password to be added
  #     -X  Specify password data to be added as a hexadecimal string
  #     -A  Allow any application to access this item without warning (insecure, not recommended!)
  #     -T  Specify an application which may access this item (multiple -T options are allowed)
  #     -U  Update item if it already exists (if omitted, the item cannot already exist)
  # 
  # By default, the application which creates an item is trusted to access its data without warning.
  # You can remove this default access by explicitly specifying an empty app pathname: -T ""
  # If no keychain is specified, the password is added to the default keychain.
  # Use of the -p or -w options is insecure. Specify -w as the last option to be prompted.
  exec /usr/bin/security add-generic-password \
    -s "be.backplane.keychain-password" \
    -a "${keyid}" \
    -T "" \
    -U \
    -w
}

main() {
  subcmd=""
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

      --)
        shift || true
        break
        ;;

      get)
        subcmd="password_get"
        ;;

      set)
        subcmd="password_set"
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
  [ -n "$subcmd" ] || usage "get or set subcmd is required"
  [ $# = 1 ] || usage "KEYID argument required"
  "$subcmd" "$*"

  exit 0
}

[ -n "$IMPORT" ] || main "$@"; exit
