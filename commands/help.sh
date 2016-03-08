
function doc--help() {
  echo 'help -- show help overview'
}

function run--help() {
  local all=
  test "${1-}" = '-a' && local all=all
  printf "%s CMD\n\n" "$0"
  help-for "$HERE/commands/" "$all" | help-prettify
  help-for "$HOME/.i_commands/" "$all" | help-prettify
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
    source "$command_script"
    local cmd;cmd="$(basename "${command_script%.*}")"
    "doc--$cmd"
  done
}

function help-prettify() {
  awk -F ' -- ' '{ printf("  %-25s -- %s\n", $1, $2) }'
}
