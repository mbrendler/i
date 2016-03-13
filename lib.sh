
function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$I_ROOT/init.sh"}
  test -f "$I_CONFIG_FILE" && source "$I_CONFIG_FILE"

  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
  LOG_FILE=${LOG_FILE-"$I_ROOT/log"}
  I_EDITOR=${I_EDITOR-${EDITOR-vim}}
  I_LOG_CMD=${I_LOG_CMD-"less +F"}
  I_GITHUB_BASE_URL=$I_GITHUB_BASE_URL
}

function pretty() {
  awk -F, "{ printf($1) }"
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

function log2() {
  log_message "$*"
  "$@" 2>> /dev/null
  # TODO synchronize output
  # "$LOG_FILE"
  local result=$?
  # echo result: $result >> "$LOG_FILE"
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
  local prefix_command_dirs=( ${command_dirs[@]/%//$prefix} )
  local cmd_script;cmd_script="$(
    get-completed-command \
      "run-$prefix-help" \
      "${1-help}" \
      "${prefix_command_dirs[@]}"
  )"
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  shift || true
  source "$cmd_script"
  "run-$prefix-$cmd" "$@"
}

function installed_features() {
  for feature_dir in "$PROJECTS_DIR"/*/.git/ ; do
    basename "${feature_dir%%/.*}"
  done
}

function get_feature_name_from_path() {
  local path_in_project="${1##$PROJECTS_DIR/}" >&2
  echo "${path_in_project%%/*}"
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

