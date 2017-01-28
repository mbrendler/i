#! /bin/bash

function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$I_ROOT/init.sh"}
  if [ -f "$I_CONFIG_FILE" ] ; then
    source "$I_CONFIG_FILE"
  fi

  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
  LOG_FILE=${LOG_FILE-"$I_ROOT/log"}
  I_EDITOR=${I_EDITOR-${EDITOR-vim}}
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
  true > "$LOG_FILE"
}

function i-view() {
  if [ -t 1 ] ; then
    vim -R "$@"
  else
    cat "$@"
  fi
}

function i-edit() {
  if [ -t 1 ] ; then
    "$I_EDITOR" "$@"
  else
    cat "$@"
  fi
}

function i-browser() {
  open -g "$@"
  log osascript -e 'tell application "Safari" to activate'
}

function wait-for-subprocesses() {
  for job in $(jobs -p) ; do
    wait "$job"
  done
}

function complete-by-list() {
  local name=$1
  local list=$2
  local uncompleted=$3
  local completed;completed="$(grep -i "$uncompleted" <<<"$list")"
  local count;count="$(wc -l <<<"$completed")"
  if [ "$count" = 1 ] && [ -n "$completed" ]; then
    echo "$completed"
  elif [ -z "$completed" ] ; then
    >&2 echo "no $name found for: '${uncompleted##^}'"
    exit 1
  else
    >&2 echo "$name '${uncompleted##^}' is ambiguous:"
    >&2 sed -E 's/^/  /' <<<"$completed"
    exit 1
  fi
}

function get-completed-command() {
  local cmd=$1
  shift
  local command_files=( $(find -L "$@" -depth 1 -name "$cmd"\*.sh 2> /dev/null) )
  if [ ${#command_files[@]} -eq 1 ] ; then
    echo "${command_files[0]}"
  elif [ ${#command_files[@]} -gt 1 ] ; then
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
      "${1-help}" \
      "${prefix_command_dirs[@]}"
  )"
  if [ -z "$cmd_script" ] ; then
    >&2 help "$prefix"
    exit 1
  fi
  local cmd;cmd="$(basename "${cmd_script%.*}")"
  shift || true
  source "$cmd_script"
  "run-$prefix-$cmd" "$@"
}

# -----------------------------------------------------------------------------

function help() {
  local prefix="$1"
  shift
  local all=
  if [ "${1-}" = '-a' ] ; then
    local all=all
    shift
  fi

  if [ "$#" -gt 0 ] ; then
    local prefix_command_dirs=( ${command_dirs[@]/%//$prefix} )
    local command_files;command_files=(
      $(find "${prefix_command_dirs[@]}" -depth 1 -name "$1"\*.sh 2> /dev/null || true)
    )
    if [ "${#command_files[@]}" -eq 1 ] ; then
      source "$command_files"
      echo "$0 $prefix $("doc-$prefix-$1")"
      echo
      ("doc-$prefix-$1-options" 2> /dev/null || true) | help-prettify
      exit 0
    fi
  fi

  local opts_doc;opts_doc=$("doc-$prefix-options" 2> /dev/null || echo "")
  if [ -n "$opts_doc" ] ; then
    printf "%s $prefix [OPTIONS] [CMD]\n\n" "$0"
    help-prettify <<< "$opts_doc"
    echo
  else
    printf "%s $prefix [CMD]\n\n" "$0"
  fi
  (for command_dir in "${command_dirs[@]}" ; do
    help-for "$prefix" "$command_dir/$prefix" "$all"
  done) | help-prettify
}

function help-for() {
  local prefix=$1
  local base=$2
  local all=${3-}
  if test "$all" = all ; then
    local match="$base/*.sh"
  else
    local match="$base/[^_]*.sh"
  fi
  for command_script in $match ; do
    test ! -f "$command_script" && continue
    source "$command_script"
    local cmd;cmd="$(basename "${command_script%.*}")"
    "doc-$prefix-$cmd"
  done
}

function help-prettify() {
  local raw;raw="$(cat)"
  local width;width="$(sed -E 's/^ *([^ ].*[^ ]) *--.*$/\1/g' <<< "$raw" | wc -L)"
  awk -F ' -- ' "{ printf(\"  %-${width}s -- %s\n\", \$1, \$2) }" <<< "$raw"
}

# -----------------------------------------------------------------------------

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
    complete-feature "$given_feature"
  elif test -n "$feature_of_pwd" ; then
    echo "$feature_of_pwd"
  else
    >&2 echo "Usage: $0 $command FEATURE"
    >&2 echo "       $0 $command # in feature directory"
    exit 1
  fi
}


function complete-feature() {
  local feature="$1"
  if ! installed_features | grep -i "^${feature}$" 2>/dev/null ; then
    complete-by-list feature "$(installed_features)" "$1"
  fi
}
