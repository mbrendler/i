#! /bin/bash

if test "${DEBUG+x}" ; then
  set -ex
fi

# because BSDs 'readlink' does not support '-f' option:
HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
COMMANDS_DIR="$HERE/commands"

source "$HERE/lib.sh"
read_config

log_clear

CMD='';
function get_completed_command() {
  local command_files=( "$COMMANDS_DIR/$1"* )
  if test -z "$1" || test ! -f ${command_files[0]} ; then
    source "$COMMANDS_DIR/help.sh"
    run_help
    exit 1
  elif test ${#command_files[@]} -eq 1 ; then
    CMD="$(basename "${command_files[0]%.*}")"
  else
    echo "command '$1' is ambiguous:"
    echo -n "  "
    for command_file in "${command_files[@]}" ; do
      echo -n " $(basename ${command_file%.*})"
    done
    exit 1
  fi
}

get_completed_command "$1"

log_message '========================================'
log_message run "$0 $*"
source "$COMMANDS_DIR/$CMD.sh"
shift
"run_$CMD" "$*"
