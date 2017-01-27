
function doc--edit() {
  echo 'edit [FEATURE] -- open editor in feature directory'
}

function run--edit() {
  local feature;feature="$(get_feature_name edit "${1-}")"
  log pushd "$PROJECTS_DIR/$feature"
  exec "$I_EDITOR"
}
