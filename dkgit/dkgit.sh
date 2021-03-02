#!/bin/sh

GIT_DEPLOY_KEY="${GIT_DEPLOY_KEY:-$(pwd)/.git_deploy_key}"

warn() {
  printf '%s %s\n' "$(date '+%FT%T')" "$*" >&2
}

die() {
  warn "FATAL:" "$@"
  exit 1
}

# always check for the deploy key
[ -f "$GIT_DEPLOY_KEY" ] \
  || die "Could not find the GIT_DEPLOY_KEY at ${GIT_DEPLOY_KEY}"

# if applicable, exec ssh with the correct arguments
if [ -n "$WRAP_SSH" ]; then
  # when this envvar is set, git is running us again as a stand-in for ssh
  exec ssh -i "$GIT_DEPLOY_KEY" -F /dev/null "$@"
fi

# safety-check before we attempt to have git call us again as an ssh stand-in
[ -f "$0" ] \
  || die "$0 isn't a file, so git won't be able to call this script"

# run git, telling it use use this script as a stand-in for ssh, set WRAP_SSH
# so that when we're called again we run in ssh-stand-in mode
export GIT_SSH="$0" WRAP_SSH="1"
exec git "$@"
