#! /bin/bash

set -euo pipefail

if test "${DEBUG+x}" ; then
  set -x
fi

# because BSDs 'readlink' does not support '-f' option:
readonly HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
readonly COMMANDS_DIR="$HERE/commands"
readonly LOCAL_COMMANDS_DIR="$HOME/.i_commands"

source "$HERE/lib.sh"

function help-and-exit() {
  source "$COMMANDS_DIR/help.sh"
  >&2 run_help
  exit 1
}

function get-completed-command() {
  local fail_action=$1
  local cmd=$2
  shift 2
  local command_files=( $(eval "ls $(IFS=, ; echo "{$*}")/$cmd*.sh 2> /dev/null") )
  if test -z "$cmd" || test "${#command_files}" -eq 0 ; then
    $fail_action
  elif test ${#command_files[@]} -eq 1 ; then
    echo "${command_files[0]}"
  else
    >&2 echo "command '$cmd' is ambiguous:"
    >&2 echo -n "  "
    for command_file in "${command_files[@]}" ; do
      >&2 echo -n " $(basename "${command_file%.*}")"
    done
    >&2 echo
    exit 1
  fi
}

function main() {
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  local cmd_script
  cmd_script="$(get-completed-command help-and-exit "${1-}" "$COMMANDS_DIR" "$LOCAL_COMMANDS_DIR")"
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  source "$cmd_script"
  shift || true
  "run_$cmd" "$@"
}

main "$@"
