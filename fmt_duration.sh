#!/bin/sh

usage() {
  self="$(basename "$0")"

  printf '%s\n' \
    "Usage: $self duration_seconds [labeled_increment [...]]" \
    "" \
    "Given a number of seconds representing a duration; print that in years," \
    "hours, minutes, seconds." \
    "" \
    "for example:" \
    "  $self 35000000" \
    "yields:" \
    "  1 year, 39 days, 20 hours, 13 minutes, 20 seconds" \
    "" \
    "Note: by default 1 year is treated as 365.25 days to account for leap" \
    "years." \
    "" \
    "You may optionally specify the labeled increments to use when" \
    "formatting the duration. Use 'singular/plural:increment_seconds' for" \
    "each increment. For example if you only want duration specified in days" \
    "and hours use the increments day/days:86400 and hour/hours:3600." \
    "" \
    "That complete example call:" \
    "  $self 1216567 day/days:86400 hour/hours:3600" \
    "yields:" \
    "  14 days, 1 hour" \
    ""
  exit 1
}

warn() {
  printf '%s %s\n' "$(date '+%FT%T')" "$*" >&2
}

die() {
  warn "$* EXITING"
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

  unset _increment _label _labeled_increments _labels _plural_label _quantity \
        _result _seconds _singular_label >/dev/null 2>&1
}

main() {
  if [ -z "$*" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
  fi

  fmt_duration "$@"

  exit 0
}

[ -n "$IMPORT" ] || main "$@"
