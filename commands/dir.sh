
function doc--dir() {
  echo 'dir [FEATURE] -- display path to feature'
}

function run--dir() {
  if test -n "${1-}" ; then
    local feature;feature="$(get_feature_name dir "$1")"
    local feature_dir="$PROJECTS_DIR/$feature"
    if test -e "$feature_dir"; then
      echo "$feature_dir"
    else
      >&2 echo "Not installed feature '$feature'"
      exit 1
    fi
  else
    echo "$PROJECTS_DIR"
  fi
}
