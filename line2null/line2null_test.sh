#!/bin/sh

testShellCheck() {
  shellcheck "${TESTING_TARGET}" || fail "shellcheck failed"
}

testUsage() {
  # invocations with any arguments should show usage information

  assertContains \
    "invocation with any arguments should output usage" \
    "$( sh -c "${TESTING_TARGET} asdf 2>&1" )" \
    "Usage:"

  assertContains \
    "invocation with -h should output usage" \
    "$( sh -c "${TESTING_TARGET} -h 2>&1" )" \
    "Usage:"

  assertContains \
    "invocation with --help should output usage" \
    "$( sh -c "${TESTING_TARGET} --help 2>&1" )" \
    "Usage:"

  # invocations without any arguments should output nothing
  assertEquals \
    "invocation without any argument should output nothing" \
    "$( sh -c "cat /dev/null | ${TESTING_TARGET} 2>&1" )" \
    ""
}

testImportMode() {
  assertEquals \
    "Import mode should output nothing" \
    "$(sh -c "export IMPORT=1; . ${TESTING_TARGET}")" \
    ""
}

testLine2NullInputs() {
  # test throughput

  assertEquals \
    "Expect one line" \
    "$(printf '%s\n' 'word one' 'word two' | line2null | xargs -0 | wc -l)" \
    "1"

  assertEquals \
    "Expect one line" \
    "$(printf '%s\n' 'word one' 'word two' | line2null | xargs -0 -n 1 | wc -l)" \
    "2"
}

oneTimeSetUp() {
  # shellcheck source=/dev/null
  IMPORT=1 . "${TESTING_TARGET}"
}

# shellcheck source=/dev/null
. "$SHUNIT_PATH"
