#!/bin/sh

TARGET="./fmt_duration.sh"

testShellCheck() {
  shellcheck "${TARGET}" || fail "shellcheck failed"
}

testImportMode() {
  got="$(sh -c "export IMPORT=1; . ${TARGET}")"
  want=""
  assertEquals "Import mode should output nothing" "$want" "$got"
}

testWarn() {
  output="$( warn testWarn 2>&1 >/dev/null | grep -E '^....-..-..T..:..:.. testWarn$' )"
  contains="testWarn"
  assertContains "test warning function output" "$output" "$contains"
}

testDie() {
  output="$( die testDie 2>&1 >/dev/null | grep -E '^....-..-..T..:..:.. testDie' )"
  contains="testDie"
  assertContains "test die function output" "$output" "$contains"
  contains="EXITING"
  assertContains "test die function output" "$output" "$contains"

  ( die "testDie2" >/dev/null 2>&1 )
  got=$?
  want=1
  assertEquals "die exit code should be 1" "$want" "$got"
}

testMain() {
  got="$(main 167212082)"
  want="5 years, 109 days, 1 hour, 48 minutes, 2 seconds"
  assertEquals "invoke with valid argument" "$want" "$got"

  output="$( main )"
  contains="Usage:"
  assertContains "invoke without args = show usage" "$output" "$contains"

  output="$( main -h 2>&1 )"
  contains="Usage:"
  assertContains "invoke with -h = show usage" "$output" "$contains"

  output="$( main --help 2>&1 )"
  contains="Usage:"
  assertContains "invoke with --help = show usage" "$output" "$contains"
}

testFmtDuration() {
  got="$(fmt_duration 0)"
  want="0 seconds"
  assertEquals "zero; 0 = 0 seconds" "$want" "$got"

  got="$(fmt_duration 1)"
  want="1 second"
  assertEquals "singular; 1 = 1 second" "$want" "$got"

  got="$(fmt_duration 2)"
  want="2 seconds"
  assertEquals "plural; 2 = 2 seconds" "$want" "$got"

  got="$(fmt_duration 86399)"
  want="23 hours, 59 minutes, 59 seconds"
  assertEquals "multiple clauses; input 1d-1s" "$want" "$got"

  got="$(fmt_duration 86400)"
  want="1 day"
  assertEquals "non-terminal singualr; input 1d" "$want" "$got"

  got="$(fmt_duration 31536000)"
  want="365 days"
  assertEquals "1y==365.25, input 365d" "$want" "$got"

  got="$(fmt_duration 31557600)"
  want="1 year"
  assertEquals "1y=365.25; input 365.25d" "$want" "$got"

  got="$(fmt_duration 31536000 second/seconds:1)"
  want="31536000 seconds"
  assertEquals "only seconds; 365d in s" "$want" "$got"

  got="$(fmt_duration 31557601 week/weeks:604800 hour/hours:3600 second/seconds:1)"
  want="52 weeks, 30 hours, 1 second"
  assertEquals "365.25d in w, h, s" "$want" "$got"
}

oneTimeSetUp() {
  # shellcheck source=/dev/null
  IMPORT=1 . ${TARGET}
}

# shellcheck source=/dev/null
. "${SHUNIT_PATH:-./shunit2}"
