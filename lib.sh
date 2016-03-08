
function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$HOME/.i"}
  test -e "$I_CONFIG_FILE" && source "$I_CONFIG_FILE"

  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
  LOG_FILE=${LOG_FILE-"$HOME/.i.log"}
  I_EDITOR=${I_EDITOR-${EDITOR-vim}}
  I_LOG_CMD=${I_LOG_CMD-"less +F"}
  I_GITHUB_BASE_URL=$I_GITHUB_BASE_URL
}

function updown() {
  log "$@" && echo up || echo down
}

function run_function_for_each_argument() {
  local function=$1
  local arg
  shift
  for arg in "$@" ; do
    "$function" "$arg"
  done
}

function log() {
  log_message "$*"
  "$@" >> "$LOG_FILE" 2>&1
  local result=$?
  echo result: $result >> "$LOG_FILE"
  return $result
}

function log_message() {
  echo "$(date): $*" >> "$LOG_FILE"
}

function log_clear() {
  rm -f "$LOG_FILE"
}

function get-completed-command() {
  local fail_action=$1
  local cmd=$2
  shift 2
  local command_files=( $(find "$@" -depth 1 -name "$cmd"\*.sh 2> /dev/null) )
  if test ${#command_files[@]} -eq 1 ; then
    echo "${command_files[0]}"
  elif test -z "$cmd" || test "${#command_files}" -eq 0 ; then
    >&2 $fail_action
    exit 1
  else
    >&2 echo "command '$cmd' is ambiguous:"
    echo ' ' "${command_files[@]##*/}" | sed 's/\.sh//g' >&2
    exit 1
  fi
}

function run-completed-command() {
  local prefix=$1
  shift
  local cmd_script;cmd_script="$(
    get-completed-command \
      "run-$prefix-help" \
      "${1-help}" \
      "$COMMANDS_DIR/$prefix" \
      "$LOCAL_COMMANDS_DIR/$prefix"
  )"
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  shift || true
  source "$cmd_script"
  "run-$prefix-$cmd" "$@"
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
  local feature_of_pwd; feature_of_pwd="$(get_feature_name_from_path "$PWD")"
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

