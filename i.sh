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

CMD=$1

if test -e "$COMMANDS_DIR/$CMD.sh" ; then
  log_message '========================================'
  log_message run "$0 $*"
  source "$COMMANDS_DIR/$CMD.sh"
  shift
  "run_$CMD" "$*"
else
  source "$COMMANDS_DIR/help.sh"
  run_help
  exit 1
fi
