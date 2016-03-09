#! /bin/bash

set -euo pipefail

if test "${DEBUG+x}" ; then
  set -x
fi

readonly HERE="$(dirname "$(readlink "${BASH_SOURCE[0]}")")"
readonly I_ROOT="$HOME/.i"
readonly COMMANDS_DIR="$HERE/commands"
readonly LOCAL_COMMANDS_DIR="$I_ROOT/commands"

source "$HERE/lib.sh"

function main() {
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  source "$COMMANDS_DIR/help.sh"
  run-completed-command "" "$@"
}

main "$@"
