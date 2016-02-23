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

function get_completed_command() {
  local cmd=$1
  shift
  local command_files=( $(ls {"$COMMANDS_DIR","$LOCAL_COMMANDS_DIR"}/"$cmd"*.sh 2> /dev/null) )
  if test -z "$cmd" || test "${#command_files}" -eq 0 ; then
    source "$COMMANDS_DIR/help.sh"
    run_help
    exit 1
  elif test ${#command_files[@]} -eq 1 ; then
    echo "${command_files[0]}"
  else
    >&2 echo "command '$cmd' is ambiguous:"
    >&2 echo -n "  "
    for command_file in "${command_files[@]}" ; do
      >&2 echo -n " $(basename ${command_file%.*})"
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
  local cmd_script;cmd_script="$(get_completed_command "${1-help}" "$COMMANDS_DIR" "$LOCAL_COMMANDS_DIR")"
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  source "$cmd_script"
  shift || true
  "run_$cmd" "$@"
}

main "$@"
