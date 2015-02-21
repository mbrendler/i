#! /bin/bash

CONFIG_FILE="$HOME/.invision"

test -e "$CONFIG_FILE" && source "$CONFIG_FILE"

INVISION_WORK="$HOME/work"  # TODO: configure in $CONFIG_FILE

SCRIPT=$0
CMD=$1

function prog_help(){
  cat << EOF
$SCRIPT CMD [OPTIONS]

  help              -- show help overview
  install [FEATURE] -- install InVision project
  installed         -- list installed features
  update [FEATURE]  -- update InVision project
EOF
}

# because BSDs 'readlink' does not support '-f' option:
HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
COMMANDS_DIR="$HERE/commands"

if test "$cmd" == help ; then
  prog_help
elif test -e "$COMMANDS_DIR/$CMD.sh" ; then
  source "$COMMANDS_DIR/$CMD.sh"
  "run_$CMD"
else
  prog_help
  exit 1
fi
