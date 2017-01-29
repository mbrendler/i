#! /bin/bash

set -euo pipefail

if test "${DEBUG+x}" ; then
  set -x
fi

function readlink-m() {
  # Fallback for realpath with python on BSD:
  realpath "$0" 2> /dev/null || python -c "import os ; print(os.path.realpath('$1'))"
}

readonly HERE="$(dirname "$(readlink-m "${BASH_SOURCE[0]}")")"
readonly I_ENVIRONMENT="${I_ENVIRONMENT:-${0##*/}}"
readonly I_ROOT="$HOME/.$I_ENVIRONMENT"

readonly COMMANDS_DIR="$HERE/commands"
readonly LOCAL_COMMANDS_DIR="$I_ROOT/commands"

if [ -p /dev/stdout ] ; then
  readonly IS_PIPE=yes
else
  readonly IS_PIPE=no
fi

command_dirs=( "$COMMANDS_DIR" "$LOCAL_COMMANDS_DIR" )

source "$HERE/lib.sh"

function main() {
  mkdir -p "$I_ROOT"
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  run-completed-command "" "$@"
}

main "$@"
