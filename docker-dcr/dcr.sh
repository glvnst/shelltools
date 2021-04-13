#!/bin/sh

SELF="$(basename "$0" ".sh")"

usage() {
  exception="$1"; shift
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  if [ "$SELF" = "dcpr" ]; then
    desc="This utility pulls the images for docker-compose services then restarts them."
  else
    desc="This utility restarts docker-compose services."
  fi

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [compose_service [...]]" \
    "" \
    "-h / --help              show this message" \
    "--pull                   pull images before the restart process" \
    "--debug                  internally enable shell 'set -x' debug output" \
    "compose_service          optional names of services to restart" \
    "" \
    "$desc" \
    "By default all services in the project directory will be restarted." \
    "" \
    "Unrecognized arguments will end argument processing; they are passed to docker-compose" \
    ""

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

note() {
  printf '### %s\n' "$*"
}

compose() {
  docker-compose "$@"
  compose_exit=$?
  if [ -n "$exit_on_compose_fail" ] && [ "$compose_exit" != "0" ]; then
    die "docker-compose exited non-zero (${compose_exit})"
  fi
  return $compose_exit
}

dcr() {
  # we vary our behavior based on the name the program is called with ($0)
  if [ "$SELF" = "dcpr" ]; then
    pull="1"
  else
    pull=""
  fi
  exit_on_compose_fail=""

  # arg-processing loop
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop
    case "$arg" in
      -h|-help|--help)
        usage
        ;;

      -p|--pull)
        pull="1"
        ;;

      --debug)
        set -x
        ;;

      --mega-turtles)
        usage "You can't handle MEGA-TURTLES."
        ;;

      --)
        break
        ;;

      *)
        # unknown arg, put it back so we can hand it off to docker-compose
        set -- "$arg" "$@"
        break
        ;;
    esac
    shift || break
  done

  if [ -n "$pull" ]; then
    note "pull"
    compose pull "$@" \
      || die "docker-compose pull had a non-zero exit"
  fi

  # note "stop"
  # compose stop "$@" # continue on failure

  note "rm"
  exit_on_compose_fail="1" compose rm --force --stop "$@" # continue on failure
  # if the service containers are still here, kill them!
  exit_on_compose_fail="1" compose ps -q "$@" | while read -r CONTAINER; do
    warn "trying kill for still-running container: " "$CONTAINER"
    # uses SIGKILL; docker rm -f is more forceful than compose's rm
    docker rm -f "$CONTAINER" || die "unable to force-remove: " "$CONTAINER"
  done

  note "up"
  compose up -d --remove-orphans --renew-anon-volumes "$@"
  up_result=$?
  [ "$up_result" = "0" ] || warn "docker-compose up exited non-zero (${up_result})"

  note "ps"
  compose ps --all "$@" # continue on failure

  note "logs"
  dc logs --tail=5 --timestamps "$@" # continue on failure

  exit $up_result
}

[ -n "$IMPORT" ] || dcr "$@"
