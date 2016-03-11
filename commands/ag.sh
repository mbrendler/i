
function doc--ag() {
  echo ag FEATURE CMD_ARGS_AG -- run 'ag' within the projects directory
}

function run--ag() {
  local feature;feature="$(get_feature_name ag "$1")"
  shift
  ag "$@" "$PROJECTS_DIR/$feature"
}
