#!/bin/sh
# simple utility for reporting information about the docker desktop vm

alpine_nsenter() {
  exec docker run \
    --rm \
    -it \
    --privileged \
    --pid=host \
    alpine:edge \
    nsenter -t 1 -m -u -n -i -- \
      "$@"
}


docker_vm_sh() {
  alpine_nsenter /bin/sh "$@"
}


docker_vm_df() {
  alpine_nsenter /bin/df /var/lib "$@"
}


docker_vm_top() {
  alpine_nsenter /usr/bin/top "$@"
}


usage() {
  [ -n "$*" ] && printf "ERROR: %s\n\n" "$*" >&2

  printf '%s\n' \
    "Usage: ${0} [-h|--help] command [command_arguments [...]]" \
    '' \
    '"command" is one of the following:' \
    '' \
    '* df - display free disk space in the docker desktop VM' \
    '* sh - run POSIX-compliant command interpreter in the docker desktop VM' \
    '* top - display sorted information about processes running in the docker desktop VM' \
    '' \
    'Additional arguments are passed to the corresponding command.' \
    >&2

  exit 1
}


main() {
  cmd="$1"; shift

  [ -n "$cmd" ] || usage

  case "$cmd" in
    -h|-help|--help)
      usage
      ;;

    df)
      docker_vm_df "$@"
      ;;

    sh)
      docker_vm_sh "$@"
      ;;

    top)
      docker_vm_top "$@"
      ;;

    *)
      usage "Unknown command ${cmd}"
      ;;
  esac

  # should be unreachable
  exit 2
}


[ -n "$IMPORT" ] || main "$@"
exit