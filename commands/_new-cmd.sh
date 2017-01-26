
function doc--_new-cmd() {
  echo '_new-cmd CMD_PATH -- name/path of the new command'
}

function doc--_new-cmd-options() {
cat <<EOF
-g -- create in global commands directory
-e -- edit newly created file
EOF
}

function run--_new-cmd() {
  commands_dir="$LOCAL_COMMANDS_DIR"
  local edit_command=echo
  while getopts ":ge" opt; do
    case $opt in
      g) commands_dir="$COMMANDS_DIR" ;;
      e) edit_command=i-edit ;;
      \?) help _new-cmd >&2 ; exit 1 ;;
    esac
  done
  shift "$((OPTIND-1))"
  local cmd_path="$1"
  local file_path="$commands_dir/$cmd_path".sh
  if [ -e "$file_path" ] ; then
    >&2 echo "$file_path does already exist"
    exit 1
  fi
  local dir;dir="$(dirname "$file_path")"
  mkdir -p "$dir"
  _new-cmd-content "$cmd_path" > "$file_path"
  "${edit_command[@]}" "$file_path"
}

function _new-cmd-content() {
  local cmd_path="$1"
  local cmd;cmd="$(basename "$cmd_path")"
  local function_name_sufix;function_name_sufix="$(tr / - <<<"$cmd_path")"
  if log grep -v '-' <<<"$function_name_sufix" ; then
    function_name_sufix="-$function_name_sufix"
  fi
  cat <<EOF

function doc-$function_name_sufix() {
  echo '$cmd -- TODO new command'
}

function run-$function_name_sufix() {
  echo "TODO: $cmd_path"
}
EOF
}
