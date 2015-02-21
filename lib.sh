
function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$HOME/.i"}
  test -e "$I_CONFIG_FILE" && source "$I_CONFIG_FILE"

  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
  LOG_FILE=${LOG_FILE-"$HOME/.i.log"}
}

function log() {
  log_message "$*"
  $* >> "$LOG_FILE" 2>&1
}

function log_message() {
  echo "$(date): $*" >> "$LOG_FILE"
}

function log_clear() {
  rm "$LOG_FILE"
}

function installed_features() {
  for feature_dir in "$PROJECTS_DIR"/* ; do
    if test -d "$feature_dir/.git" ; then
      basename "$feature_dir"
    fi
  done
}
