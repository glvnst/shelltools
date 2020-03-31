#!/bin/sh

testShellCheck() {
  shellcheck "${TESTING_TARGET}" || fail "shellcheck failed"
}

testUsage() {
  # no args, -h and --help invocations should contain the word usage

  assertContains \
    "invocation without arguments should output usage" \
    "$( sh -c "${TESTING_TARGET} 2>&1" )" \
    "Usage:"

  assertContains \
    "invocation without arguments should output usage" \
    "$( sh -c "${TESTING_TARGET} -h 2>&1" )" \
    "Usage:"

  assertContains \
    "invocation without arguments should output usage" \
    "$( sh -c "${TESTING_TARGET} --help 2>&1" )" \
    "Usage:"
}

testImportMode() {
  assertEquals \
    "Import mode should output nothing" \
    "$(sh -c "export IMPORT=1; . ${TESTING_TARGET}")" \
    ""
}

testFmtDurationInputs() {
  assertEquals \
    "zero; 0 = 0 seconds" \
    "$(fmt_duration 0)" \
    "0 seconds"

  assertEquals \
    "singular; 1 = 1 second" \
    "$(fmt_duration 1)" \
    "1 second"

  assertEquals \
    "plural; 2 = 2 seconds" \
    "$(fmt_duration 2)" \
    "2 seconds"

  assertEquals \
    "multiple clauses; input 1d-1s" \
    "$(fmt_duration 86399)" \
    "23 hours, 59 minutes, 59 seconds"

  assertEquals \
    "non-terminal singualr; input 1d" \
    "$(fmt_duration 86400)" \
    "1 day"

  assertEquals \
    "1y==365.25, input 365d" \
    "$(fmt_duration 31536000)" \
    "365 days"

  assertEquals \
    "1y=365.25; input 365.25d" \
    "$(fmt_duration 31557600)" \
    "1 year"

  assertEquals \
    "only seconds; 365d in s" \
    "$(fmt_duration 31536000 second/seconds:1)" \
    "31536000 seconds"

  assertEquals \
    "365.25d in w, h, s" \
    "$(fmt_duration 31557601 week/weeks:604800 hour/hours:3600 second/seconds:1)" \
    "52 weeks, 30 hours, 1 second"
}

oneTimeSetUp() {
  # shellcheck source=/dev/null
  IMPORT=1 . "${TESTING_TARGET}"
}

# shellcheck source=/dev/null
. "$SHUNIT_PATH"
