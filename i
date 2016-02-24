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

function action-and-exit() {
  local action=$1
  $action
  exit 1
}

function get-completed-command() {
  local fail_action=$1
  local cmd=$2
  shift 2
  if test "$#" -eq 1 ; then
    local prefixes=$1
  else
    local prefixes;prefixes=$(IFS=, ; echo "{$*}")
  fi
  local command_files=( $(eval "ls $prefixes/$cmd*.sh 2> /dev/null") )
  if test -z "$cmd" || test "${#command_files}" -eq 0 ; then
    >&2 action-and-exit "$fail_action"
  elif test ${#command_files[@]} -eq 1 ; then
    echo "${command_files[0]}"
  else
    >&2 echo "command '$cmd' is ambiguous:"
    echo ' ' "${command_files[@]}" | sed -E 's/[^ ]+\/([^\/ ]+).sh/\1/g' >&2
    exit 1
  fi
}

function run-completed-command() {
  local prefix=$1
  shift
  local cmd_script
  cmd_script="$(
    get-completed-command \
      "run-$prefix-help" \
      "${1-help}" \
      "$COMMANDS_DIR/$prefix" \
      "$LOCAL_COMMANDS_DIR/$prefix"
  )"
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  shift || true
  source "$cmd_script"
  "run-$prefix-$cmd" "$@"
}

function main() {
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  source "$COMMANDS_DIR/help.sh"
  run-completed-command "" "$@"
}

main "$@"
