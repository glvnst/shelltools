#!/bin/sh

# NOTE: collect is better as a shell script than a shell function because
# it is extremely useful with external tools like xargs.
#
# ...BUT consider adding this shell function to your profile to augment the
# collect command in ~/bin/
#
# cdcollect() {
#   # e.g. collect somepdfs *.pdf && cd somepdfs  
#   collect "$@" && cd "$1" || return 1
# }

usage() {
  printf '%s\n' \
    "Usage: collect targetpath sourcepath [...]" \
    "" \
    "A combination of mv and mkdir. Creates the given target directory" \
    "if necessary then moves the given files into the target." \
    "" \
    "E.G.:" \
    "collect pdfs *.pdf ~/Desktop/*.pdf" \
    ""\
  >&2

  exit 1
}

warn() {
  printf "%s %s %s\n" "$(date '+%FT%T')" "$(basename "$0")" "$*" >&2
}

die() {
  warn "$* EXITING"
  exit 1
}

collect() { 
  if [ "$1" = '-h' ] || [ "$1" = '--help' ] || [ "$#" -lt 2 ]; then
    usage
  fi
  target=$1; shift

  # Make the directory if necessary
  [ -d "$target" ] \
    || mkdir -p -- "$target" \
    || die "couldn't create target directory ${target}"

  # collect the things into the thing
  mv -i -- "$@" "${target}/" \
    || die "couldn't move the specified items into ${target}"

  exit 0
}

collect "$@"
