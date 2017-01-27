
function doc--dir() {
  echo 'dir [FEATURE] -- display path to feature'
}

function run--dir() {
  local dir="$PROJECTS_DIR"
  if [ -n "${1-}" ] ; then
    local feature;feature="$(get_feature_name dir "$1")"
    dir="$dir/$feature"
  fi
  echo "$dir"
}
