
function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$HOME/.i"}
  test -e "$I_CONFIG_FILE" && source "$I_CONFIG_FILE"

  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
  LOG_FILE=${LOG_FILE-"$HOME/.i.log"}
  I_EDITOR=${I_EDITOR-${EDITOR-vim}}
  I_GITHUB_BASE_URL=$I_GITHUB_BASE_URL
}

function yesno() {
  log $* && echo yes || echo no
}

function log() {
  log_message "$*"
  $* >> "$LOG_FILE" 2>&1
}

function log_message() {
  echo "$(date): $*" >> "$LOG_FILE"
}

function log_clear() {
  rm -f "$LOG_FILE"
}

function installed_features() {
  for feature_dir in "$PROJECTS_DIR"/* ; do
    if test -d "$feature_dir/.git" ; then
      basename "$feature_dir"
    fi
  done
}

function get_feature_name_from_path() {
  local path="$1"
  echo "$path" | sed -ne "s#^$PROJECTS_DIR/\\([^/]*\\).*\$#\\1#p"
}

function get_feature_name() {
  local command="$1"
  local given_feature="$2"
  local feature_of_pwd="$(get_feature_name_from_path "$PWD")"
  if test -n "$given_feature" ; then
    echo "$given_feature"
  elif test -n "$feature_of_pwd" ; then
    echo "$feature_of_pwd"
  else
    >&2 echo "Usage: $0 $command FEATURE"
    >&2 echo "       $0 $command # in feature directory"
    exit 1
  fi
}

