
function doc_dir() {
  echo '  dir FEATURE              -- display path to feature'
}

function run_dir() {
  local feature="$1"
  local feature_dir="$PROJECTS_DIR/$feature"
  if test -n "$feature" ; then
    if test -e "$feature_dir"; then
      echo "$feature_dir"
    else
      >&2 echo "Not installed feature '$feature'"
      exit 1
    fi
  else
    >&2 echo "Usage: $0 dir FEATURE"
    exit 1
  fi
}
