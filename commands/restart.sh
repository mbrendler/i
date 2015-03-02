
function doc_restart() {
  echo "  restart [FEATURE] -- restart pow"
}

function restart_feature() {
  local feature=$1
  local feature_dir="$PROJECTS_DIR/$feature"
  if test -d "$feature_dir" && test -f "$feature_dir/config.ru" ; then
    mkdir -p "$feature_dir/tmp"
    touch "$feature_dir/tmp/restart.txt"
    echo "$feature restarted"
  fi
}

function run_restart() {
  if test $# -eq 0 || test -z "$1" ; then
    local feature="$(get_feature_name_from_path "$PWD")"
    if test -n "$feature" ; then
      restart_feature "$feature"
    else
      >&2 echo "Usage: $0 restart FEATURE"
      >&2 echo "       $0 restart --all"
      >&2 echo "       $0 restart # in feature directory"
    exit 1
    fi
  elif test "$1" = '--all' || test "$1" = '-a' ; then
    local features=$(installed_features)
    for feature in $features ; do
      restart_feature "$feature"
    done
  else
    restart_feature "$*"
  fi
}
