
function doc_help() {
  echo "  help                     -- show help overview"
}

function run_help() {
  local all=${1-}
  echo "$0 CMD [OPTIONS]"
  echo
  help-for "$HERE/commands/"
  help-for "$HOME/.i_commands/"
}

function help-for() {
  local base=$1
  if test "$all" = '--all' -o "$all" = '-a' ; then
    local match="$base/*.sh"
  else
    local match="$base/[^_]*.sh"
  fi
  for command_script in $match ; do
    source "$command_script"
    "doc_$(basename "${command_script%.*}")"
  done
}
