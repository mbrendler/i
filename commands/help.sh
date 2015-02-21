
function doc_help() {
  echo "  help              -- show help overview"
}

function run_help() {
  echo "$0 CMD [OPTIONS]"
  echo
  for command_script in $HERE/commands/*.sh ; do
    source "$command_script"
    "doc_$(basename "${command_script%.*}")"
  done
}
