#!/bin/sh

testShellCheck() {
  shellcheck "${TESTING_TARGET}" || fail "shellcheck failed"
}

testImportMode() {
  output=$(sh -c "export IMPORT=1; . ${TESTING_TARGET}")

  assertEquals "Import mode should output nothing" "$output" ""
}

testFmtDuration() {
  assertEquals "input 0" "$(fmt_duration 0)" "0 seconds"
  assertEquals "input 1" "$(fmt_duration 1)" "1 second"
  assertEquals "input 2" "$(fmt_duration 2)" "2 seconds"

  assertEquals \
    "input 1d-1s" \
    "$(fmt_duration 86399)" \
    "23 hours, 59 minutes, 59 seconds"

  assertEquals \
    "input 1d" \
    "$(fmt_duration 86400)" \
    "1 day"

  assertEquals \
    "input 1d+2s" \
    "$(fmt_duration 86402)" \
    "1 day, 2 seconds"

  assertEquals \
    "input 60*60*24*365.25" \
    "$(fmt_duration 31536000)" \
    "365 days"

  assertEquals \
    "input 365d + 6h - 1s" \
    "$(fmt_duration 31557599)" \
    "365 days, 5 hours, 59 minutes, 59 seconds"

  assertEquals \
    "input 365d + 6h" \
    "$(fmt_duration 31557600)" \
    "1 year"

  assertEquals \
    "input 365d in s" \
    "$(fmt_duration 31536000 second/seconds:1)" \
    "31536000 seconds"

  assertEquals \
    "input 365.25d in w, h, s" \
    "$(fmt_duration 31557601 week/weeks:604800 hour/hours:3600 second/seconds:1)" \
    "52 weeks, 30 hours, 1 second"
}

oneTimeSetUp() {
  IMPORT=1 . "${TESTING_TARGET}"
}

# shellcheck source=/dev/null
. "$SHUNIT_PATH"
