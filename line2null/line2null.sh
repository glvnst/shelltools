#!/bin/sh
# converts newlines to nulls, useful with xargs -0
# installed_name:line2null

usage() {
  self="$(basename "$0")"

  printf '%s\n' \
    "Usage: $self [-h|--help]" \
    "" \
    "This utility converts linefeeds on the standard input into null" \
    "characters. This can be useful in combination with the xargs -0" \
    "facility." \
    ""

  exit 1
}

line2null() {
  exec tr '\n' '\0'
}

main() {
  [ -z "$*" ] || usage

  line2null
}

[ -n "$IMPORT" ] || main "$@"