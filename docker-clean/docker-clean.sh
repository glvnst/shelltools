#!/bin/sh

# part of hack to get around gnu xargs behavior
XARGS="xargs"

# the use of these variables helps testing and debugging
DOCKER_QUERY="docker"
DOCKER_MUTATE="docker"

# specify these in seconds
MAX_AGE_CONTAINER="${MAX_AGE_CONTAINER:-14400}"
MAX_AGE_IMAGE="${MAX_AGE_IMAGE:-7776000}"
MAX_AGE_NETWORK="${MAX_AGE_NETWORK:-604800}"

usage() {
  self="$(basename "$0")"

  age_str_container="$(fmt_duration "$MAX_AGE_CONTAINER")"
  age_str_image="$(fmt_duration "$MAX_AGE_IMAGE")"
  age_str_network="$(fmt_duration "$MAX_AGE_NETWORK")"

  printf '%s\n' \
    "Usage: $self [-h | --help]" \
    "" \
    "This utility removes bits of docker detritus, similar to the standard" \
    "command 'docker system prune' -- this utility makes some choices about" \
    "what to remove:" \
    "" \
    "* Stopped containers older than ${age_str_container}" \
    "* Dangling images" \
    "* Other images older than ${age_str_image}" \
    "* Unused networks older than ${age_str_network}" \
    "* Dangling anonymous volumes (vols w/ 32-character hexadecimal names)" \
    "" \
    "You can override these times by setting the following variables in the" \
    "environment (values must be in seconds, current/default values shown):" \
    "" \
    "MAX_AGE_CONTAINER=${MAX_AGE_CONTAINER}" \
    "MAX_AGE_IMAGE=${MAX_AGE_IMAGE}" \
    "MAX_AGE_NETWORK=${MAX_AGE_NETWORK}" \
    "" \
    "Example command-line invocation using different timing:" \
    "\$ MAX_AGE_CONTAINER=120 MAX_AGE_IMAGE=14400 $self" \
    ""

  exit 1
}


fmt_duration() {
  # documentation repeated here for copy/paste into other scripts
  # takes a number of seconds and prints it in years, hours, minutes, seconds
  #
  # for example:
  #   fmt_duration 35000000
  # yields:
  #   1 year, 39 days, 20 hours, 13 minutes, 20 seconds
  #
  # Note: by default 1 year is treated as 365.25 days to account for leap years
  #
  # You may optionally specify the labeled increments to use when formatting
  # the duration. Use "singular/plural:seconds" for each increment. For example
  # if you only want duration specified in days and hours use the increments
  # day/days:86400 hour/hours:3600.
  #
  # The complete example call:
  #   fmt_duration 1216567 day/days:86400 hour/hours:3600
  # yields:
  #   14 days, 1 hour
  #
  # This function makes heavy use of POSIX shell Parameter Expansion for
  # string manipulations, see:
  # https://pubs.opengroup.org/onlinepubs/009695399/utilities/xcu_chap02.html

  _seconds=${1:-0}; shift
  _labeled_increments=${*:-'year/years:31557600' \
                           'day/days:86400' \
                           'hour/hours:3600' \
                           'minute/minutes:60' \
                           'second/seconds:1'}
  _result=""

  for _increment in $_labeled_increments; do
    _labels="${_increment%%:*}"
    _increment="${_increment##*:}"

    _singular_label="${_labels%%/*}"
    _plural_label="${_labels##*/}"

    if [ "$_seconds" -ge "$_increment" ]; then
      _quantity=$((_seconds / _increment))
      if [ "$_quantity" -eq 1 ]; then
        _label="$_singular_label"
      else
        _label="$_plural_label"
      fi
      _seconds=$(( _seconds - (_quantity * _increment) ))
      _result="${_result}, ${_quantity} ${_label}"
    fi
  done

  if [ -z "$_result" ]; then
    _result="0 ${_plural_label}"
  fi

  printf '%s\n' "${_result#*, }"

  unset _increment _label _labeled_increments _labels _plural_label \
    _quantity _result _seconds _singular_label
}

clean_containers() {
  $DOCKER_MUTATE container prune \
    --filter "until=${MAX_AGE_CONTAINER}s" \
    --force
}

clean_images() {
  $DOCKER_MUTATE image prune \
    --force
  $DOCKER_MUTATE image prune \
    --all \
    --filter "until=${MAX_AGE_IMAGE}s" \
    --force
}

clean_networks() {
  $DOCKER_MUTATE network prune \
    --filter "until=${MAX_AGE_NETWORK}s" \
    --force
}

clean_volumes() {
  $DOCKER_QUERY volume ls \
    --quiet \
    --filter dangling=true \
  | grep -E '^[0-9a-f]{64}$' \
  | $XARGS \
    $DOCKER_MUTATE volume rm --
}

main() {
  [ -z "$*" ] || usage

  # adjust for gnu xargs behavior
  if sh -c 'true | xargs --no-run-if-empty >/dev/null 2>&1'; then
    XARGS="xargs --no-run-if-empty"
  fi

  for component in container image network volume; do
    "clean_${component}s" | sed "s/^/${component}: /g"
  done
}

[ -n "$IMPORT" ] || main "$@"
