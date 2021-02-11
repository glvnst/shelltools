#!/bin/sh
# simple utility for reporting information about docker volumes

DOCKER_INTERACTIVE=""

busybox_all_volumes() {
  # we're building the docker command in reverse
  # implicitly the arguments to this function (which form the
  # docker "CMD" / entrypoint arguments) appear first

  # next we add the docker image
  set -- "busybox:latest" "$@"

  # finally we have the arguments to the docker run command (which include the
  # volumes)
  for volume in $(docker volume ls -q); do
    set -- --volume="${volume}:/volumes/${volume}:ro" "$@"
  done

  [ -n "$DOCKER_INTERACTIVE" ] && set -- -it "$@"

  [ -n "$DEBUG" ] && set -x
  exec docker run \
    --rm \
    --entrypoint "/bin/sh" \
    --workdir "/volumes" \
    "$@" 
}


docker_volume_du() {
  busybox_all_volumes -c "/bin/du -hs *"
}


docker_volume_sh() {
  DOCKER_INTERACTIVE=1
  busybox_all_volumes
}


usage() {
  [ -n "$*" ] && printf "ERROR: %s\n\n" "$*" >&2

  printf '%s\n' \
    "Usage: ${0} [-h|--help] command [command_arguments [...]]" \
    '' \
    '"command" is one of the following:' \
    '' \
    '* du - display disk usage statistics for all named volumes on the system' \
    '* sh - run POSIX-compliant command interpreter with all named volumes attached' \
    '' \
    'Additional arguments are NOT accepted.' \
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

    du)
      docker_volume_du "$@"
      ;;

    sh)
      docker_volume_sh "$@"
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