#!/bin/sh

usage() {
  this="$(basename "$0")"

  printf ' %s\n' \
    "" \
    "Usage: ${this} dir [...]" \
    "" \
    "This utility moves the contents of the given directories into the" \
    "current working directory. Subsequently the given directories are" \
    "removed." \
    "" \
    "For example, the command: \"${this} example_prog\"" \
    "will move the contents of the example_prog directory into the" \
    "current working directory and delete the now-empty directory" \
    "example_prog." \
    "" \
    ".                              [ same ]" \
    "./example_prog                 [ removed ]" \
    "./example_prog/.env            ->  ./.env" \
    "./example_prog/README.md       ->  ./README.md" \
    "./example_prog/some_deps       ->  ./some_deps" \
    "./example_prog/some_deps/dep1  ->  ./some_deps/dep1" \
    "./example_prog/some_deps/dep2  ->  ./some_deps/dep2" \
    "./example_prog/src             ->  ./src" \
    "./example_prog/src/main.c      ->  ./src/main.c" \
    "" \
    "In this case ${this} simply replaces the following commands:" \
    "mv example_prog/{.*,*} ./ \ " \
    "&& rmdir example_prog" \
    "" \
    "However this utility handles edge cases that can complicate that simple" \
    "approach, such as the subdirectory containing an item with the same " \
    "name as the subdirectory (e.g. example_prog/example_prog)" \
    ""
  
  exit 1
}

warn() {
  printf '%s %s\n' "$(date '+%FT%T')" "$*" >&2
}

die() {
  warn "FATAL: " "$@"
  exit 1
}

mvtemp() {
  src_path="$1"; shift
  src_parent="$(dirname "$src_path")"
  success=""

  : $(( i=0 ))
  while [ "$i" -lt 256 ]; do
    dest_name="tmp.movehere.${i}"
    dest_path="${src_parent}/${dest_name}"
    [ -d "$dest_path" ] && continue
    [ -d "${src_path}/${dest_name}" ] && continue
    if mv -vn -- "$src_path" "$dest_path" >&2; then
      success=1
      break
    fi
    : $(( i += 1 ))
  done

  if [ -n "$success" ]; then
    printf '%s' "$dest_path"
  else
    printf ""
  fi
}

main() {
  # show usage info if there are no arguments or -h/--help arguments
  if [ -z "$*" ] || [ "$1" = '-h' ] || [ "$1" = '--help' ]; then
    usage
  fi

  # make sure all the arguments are valid directories before we do anything
  for src in "$@"; do
    [ -d "$src" ] || die "\"${src}\" is not a directory"
  done

  for src in "$@"; do
    tmp_path="$(mvtemp "$src")"
    [ -n "$tmp_path" ] || die "mvtemp failed"

    if find "$tmp_path" \
      -mindepth 1 \
      -maxdepth 1 \
      -not '(' -name '.' -o -name '..' ')' \
      -exec mv -vn -- '{}' './' ';';
    then
      { set -x ; rmdir -- "$tmp_path"; } || die "rmdir failed"
    else
      die "find failed to work on ${tmp_path}"
    fi
  done
  
  exit 0
}

main "$@"
