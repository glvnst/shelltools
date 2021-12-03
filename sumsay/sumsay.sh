#!/bin/sh
# sumsay: a utility for audibly reading checksums
SELF="$(basename "$0" ".sh")"

VOICE="tom"

sumsay() {
  for arg in "$@"; do
    if [ -r "$arg" ]; then
      # if this is a file on disk, we calculate the sum
      arg="${arg}: $(shasum -a 256 "$arg" \
        | awk '{gsub(/./,"& ",$1); print $1}')"
    else
      # if it is not a file, we assume it is a literal sum
      arg="literal checksum: $(printf '%s' "$arg" \
        | awk '{gsub(/./,"& "); print}')"
    fi

    say -i -v "$VOICE" "$arg"
  done
}

usage() {
  exception="$1"; shift
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [arg [...]]" \
    "" \
    "-h / --help   show this message" \
    "--voice VOICE sets the TTS voice to the given argument. (default: $VOICE)" \
    "--list-voices lists the available voices and exit" \
    "arg           filename or literal string. if it is a regular file, its" \
    "              SHA-256 checksum is calculated and spoken using the macOS" \
    "              'say' command. If the arg is not a filename it is assumed" \
    "              to be a checksum itself and it is spoken." \
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
  if [ "$(uname -s)" != "Darwin" ]; then
    warn "This utility was designed to work on macOS computers, it will not work unless you have a 'say' command"
  fi

  # arg-processing loop
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop; if you break in the loop don't forget to shift first
    case "$arg" in
      -h|-help|--help)
        usage
        ;;

      --mega-turtles)
        usage "You can't handle MEGA-TURTLES."
        ;;

      --voice)
        shift || die "the --voice option requires an argument"
        VOICE="$1"
        ;;

      --list-voices)
        exec say -v '?'
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

  [ -z "$*" ] && usage
  sumsay "$@"

  exit 0
}

[ -n "$IMPORT" ] || main "$@"; exit

