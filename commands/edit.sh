
function doc_edit() {
  echo '  edit [FEATURE]    -- open editor in feature directory'
}

function run_edit() {
  local feature="$(get_feature_name github "$1")"
  local feature_dir="$PROJECTS_DIR/$feature"
  if test -n "$feature" ; then
    if test -e "$feature_dir"; then
      log pushd "$feature_dir"
      shift
      "$I_EDITOR" "$@"
      log popd
    else
      >&2 echo "Not installed feature '$feature'"
      exit 1
    fi
  fi
}
