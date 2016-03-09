
function doc--help() {
  echo 'help -- show help overview'
}

function run--help() {
  local all=
  test "${1-}" = '-a' && local all=all
  printf "%s CMD\n\n" "$0"
  help-for "$COMMANDS_DIR" "$all" | help-prettify
  help-for "$LOCAL_COMMANDS_DIR" "$all" | help-prettify
}

function help-for() {
  local base=$1
  local all=${2-}
  if test "$all" = all ; then
    local match="$base/*.sh"
  else
    local match="$base/[^_]*.sh"
  fi
  for command_script in $match ; do
    if [ -f "$command_script" ] ; then
      source "$command_script"
      local cmd;cmd="$(basename "${command_script%.*}")"
      "doc--$cmd"
    fi
  done
}

function help-prettify() {
  awk -F ' -- ' '{ printf("  %-25s -- %s\n", $1, $2) }'
}
