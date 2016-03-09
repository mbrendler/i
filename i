#! /bin/bash

set -euo pipefail

if test "${DEBUG+x}" ; then
  set -x
fi

function readlink-m() {
  # BSDs readlink does not support -m option:
  python -c "import os ; print(os.path.realpath('$1'))"
}

readonly HERE="$(dirname "$(readlink-m "${BASH_SOURCE[0]}")")"
readonly I_ENVIRONMENT="${I_ENVIRONMENT:-$(basename "$0")}"
readonly I_ROOT="$HOME/.$I_ENVIRONMENT"
readonly COMMANDS_DIR="$HERE/commands"
readonly LOCAL_COMMANDS_DIR="$I_ROOT/commands"

source "$HERE/lib.sh"

function main() {
  mkdir -p "$I_ROOT"
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  source "$COMMANDS_DIR/help.sh"
  run-completed-command "" "$@"
}

main "$@"
