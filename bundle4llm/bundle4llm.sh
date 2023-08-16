#!/bin/sh
# bundle4llm: CLI util for bundling the contents of a git workdir into an LLM prompt
set -eu
SELF=$(basename "$0" '.sh')

OUTPUT_FILE_PATH="${OUTPUT_FILE_PATH:-${HOME}/Desktop/codebase-bundle.txt}"
LIST_BUNDLE_PATH="${LIST_BUNDLE_PATH:-}"
WORKDIR_PATH="${WORKDIR_PATH:-.}"


usage() {
  exception="${1:-}"
  [ -n "$exception" ] && printf 'ERROR: %s\n\n' "$exception"

  printf '%s\n' \
    "Usage: $SELF [-h|--help] [WORKDIR_PATH]" \
    "" \
    "-h / --help   show this message" \
    "-d / --debug  print additional debugging messages" \
    "" \
    "--output-file OUTPUT_FILE_PATH  specify a different output path (default: ${OUTPUT_FILE_PATH})" \
    "--list-bundle LIST_BUNDLE_PATH  list the contents of the given bundle then exit" \
    "" \
    "WORKDIR_PATH  the git workdir to encode (default: ${WORKDIR_PATH})" \
    "" \
    "CLI util for bundling the contents of a git workdir into an LLM prompt" \
    "" # no trailing slash

  [ -n "$exception" ] && exit 1
  exit 0
}

log() {
  printf '%s %s %s\n' "$(date '+%FT%T%z')" "$SELF" "$*" >&2
}

die() {
  log "FATAL:" "$@"
  exit 1
}

write_llm_prompt() {
  cat <<EOM
Below is a base64-encoded POSIX.1-2001 compliant cpio archive stream containing
a sofware project, (hopefully including a README and well-commented code).

Please put on your expert software developer thinking cap and provide your
highest quality analysis of this codebase. Focus on:

* How well it follows established best practices
* Opportunities to improve code quality
* API design feedback
* Test coverage gaps
* Creative ways to enhance maintainability and usability

I'm excited to leverage your full capabilities as an AI assistant to provide
thoughtful, actionable suggestions to improve this code. Please go beyond
superficial responses and showcase your ability to deeply analyze a codebase.
Ask clarifying questions as needed.

Let's begin our thoughtful code review of the following code:

EOM
}

bundle_workdir() {
  tree_path="${1:?undefined}"; shift || die "bundle_workdir requires a tree_path argument"
  (
    cd "${tree_path}"
    # we're using ripgrep instead of find because it supports .gitignore which
    # is a critical element in keeping repo size down
    rg --files --hidden --glob '!.git' "$@" \
      | cpio -omud \
      | base64
  )
}

make_bundle() {
  bundle_repo_path="${1:?required}"; shift || die "make_bundle requires a bundle_repo_path argument"
  bundle_output_file_path="${1:?required}"; shift || die "make_bundle requires an bundle_output_file_path argument"

  [ -d "$bundle_repo_path" ] || die "the specified path (${bundle_repo_path}) doesn't exist"
  [ -d "${bundle_repo_path}/.git" ] || die "the specified path (${bundle_repo_path}) doesn't contain a git repo"

  log "making bundle of \"${bundle_repo_path}\" in \"${bundle_output_file_path}\"..."
  {
    write_llm_prompt;
    printf '%s\n' '```';
    bundle_workdir "${bundle_repo_path}";
    printf '%s\n' '```';
  } >"$bundle_output_file_path"

  log "done"
}

list_contents() {
  bundle_path="${1:?undefined}"; shift || die "list_contents requires a bundle_path argument"

  [ -f "$bundle_path" ] || die "list_contents: the given bundle file \"${bundle_path}\" doesn't exist"

  log "listing contents of bundle \"${bundle_path}\":"

  # macOS sed was letting me down, but if I'm using perl this whole tool should
  # be written in a better language than posix sh
  perl -ne 'print if /^```$/.../^```$/ and !/^```$/' "${bundle_path}" \
    | base64 -d \
    | cpio -it

  wc -c "$bundle_path" | perl -pe 's/^\s*(\d+)\s+(.+)$/$2: $1 bytes/'
}

main() {
  # sanity-checks
  if ! rg -V >/dev/null 2>&1; then
    die "We need ripgrep (rg), please install it"
  fi
  if ! cpio --version >/dev/null 2>&1; then
    die "We need cpio, please install it"
  fi
  if ! base64 --help >/dev/null 2>&1; then
    die "We need base64, please install it"
  fi
  if ! perl --version >/dev/null 2>&1; then
    die "We need perl (for now), please install it"
  fi


  # arg-processing loop
  while [ $# -gt 0 ]; do
    arg="$1" # shift at end of loop; if you break in the loop don't forget to shift first
    case "$arg" in
      -h|-help|--help)
        usage
        ;;

      -d|--debug)
        set -x
        ;;

      --mega-turtles)
        usage "You can't handle MEGA-TURTLES."
        ;;

      --output-file)
        shift || usage "--output-file requires an argument"
        OUTPUT_FILE_PATH="$1"
        ;;

      --list-bundle)
        shift || usage "--list requires a bundle path argument"
        LIST_BUNDLE_PATH="$1"
        ;;

      --)
        shift || true
        break
        ;;

      *)
        # unknown arg, leave it back in the positional params
        break
        ;;
    esac
    shift || break
  done

  # ensure required environment variables are set
  # : "${USER:?the USER environment variable must be set}"

  # do things
  if [ -n "$LIST_BUNDLE_PATH" ]; then
    list_contents "$LIST_BUNDLE_PATH" || die "failed to list bundle contents"
    exit 0
  fi

  if [ -n "$*" ]; then
    [ "$#" -eq "1" ]  || die "we only accept a single WORKDIR_PATH positional argument"
    WORKDIR_PATH="$1"
  fi
  make_bundle "$WORKDIR_PATH" "$OUTPUT_FILE_PATH" || die "failed to make bundle"
  list_contents "$OUTPUT_FILE_PATH" || die "failed to list bundle contents"

  exit 0
}

main "$@"
# shellcheck disable=SC2317
exit

