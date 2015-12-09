#! /bin/bash

set -euo pipefail

if test "${DEBUG+x}" ; then
  set -x
fi

# because BSDs 'readlink' does not support '-f' option:
readonly HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
readonly COMMANDS_DIR="$HERE/commands"

source "$HERE/lib.sh"

function get_completed_command() {
  local command_files=( "$COMMANDS_DIR/$1"* )
  if test -z "$1" || test ! -f ${command_files[0]} ; then
    source "$COMMANDS_DIR/help.sh"
    run_help
    exit 1
  elif test ${#command_files[@]} -eq 1 ; then
    basename "${command_files[0]%.*}"
  else
    >&2 echo "command '$1' is ambiguous:"
    >&2 echo -n "  "
    for command_file in "${command_files[@]}" ; do
      >&2 echo -n " $(basename ${command_file%.*})"
    done
    exit 1
  fi
}

function main() {
  read_config
  log_clear

  log_message '========================================'
  log_message run "$0 $*"
  local cmd; cmd=$(get_completed_command "$1")
  source "$COMMANDS_DIR/$cmd.sh"
  shift
  "run_$cmd" "$@"
}

main "$@"
