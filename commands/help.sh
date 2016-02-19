
function doc_help() {
  echo "  help                     -- show help overview"
}

function run_help() {
  local all=${1-}
  echo "$0 CMD [OPTIONS]"
  echo
  if test "$all" = '--all' -o "$all" = '-a' ; then
    local match="$HERE/commands/*.sh"
  else
    local match="$HERE/commands/[^_]*.sh"
  fi
  for command_script in $match ; do
    source "$command_script"
    "doc_$(basename "${command_script%.*}")"
  done
}
