
function run_dir() {
  local feature="$1"
  local feature_dir="$PROJECTS_DIR/$feature"
  if test -n "$feature" ; then
    if test -e "$feature_dir"; then
      echo "$feature_dir"
    else
      echo "Not installed feature '$feature'"
    fi
  else
    echo "Usage: $0 dir FEATURE"
  fi
}
