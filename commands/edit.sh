
function doc_edit() {
  echo '  edit [FEATURE]           -- open editor in feature directory'
}

function run--edit() {
  local feature ; feature="$(get_feature_name edit "${1-}")"
  local feature_dir="$PROJECTS_DIR/$feature"
  if test -n "$feature" ; then
    if test -e "$feature_dir"; then
      log pushd "$feature_dir"
      test -n "${1-}" && shift
      exec "$I_EDITOR" "$@"
    else
      >&2 echo "Not installed feature '$feature'"
      exit 1
    fi
  fi
}
