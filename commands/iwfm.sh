#! /bin/bash

function doc_iwfm() {
  echo '  iwfm CMD                 -- work with iWFM-wine'
}

function run_iwfm() {
  local cmd=${1-help}
  shift || true
  log pushd "$PROJECTS_DIR/iwfm-wine"
  case "$cmd" in
    r*) run_function_for_each_argument run_iwfm_reset "$@" ;;
    star*) run_function_for_each_argument run_iwfm_start "$@" ;;
    sto*) run_function_for_each_argument run_iwfm_stop "$@" ;;
    stat*) run_iwfm_status ;;
    li*) run_iwfm_list ;;
    _list-iwfms) run_iwfm_list ;;
    lo*) run_iwfm_log "$1" ;;
    c*) run_iwfm_edit_config "$1" ;;
    *) run_iwfm_help ;;
  esac
  log popd
}

function run_iwfm_reset() {
  local name=$1
  local type; type=$(iwfm_type_by_name "$name")
  local database=$name
  local iwfm_was_running=0
  log iwfm_is_running iescon "$name" && iwfm_was_running=1
  test ! "$type" = injixo && database=default
  test $iwfm_was_running -eq 1 && run_iwfm_stop "$name"
  rake "server:$type:db:reset[$database,31]"
  test $iwfm_was_running -eq 1 && run_iwfm_start "$name"
}

function run_iwfm_start() {
  local name=$1
  local type; type=$(iwfm_type_by_name "$name")
  if log iwfm_is_running iescon "$name" ; then
    echo "iWFM $name is already running"
    return
  fi
  until log iwfm_is_startup_completed iescon "$name" ; do
    if ! log iwfm_is_running iescon "$name" ; then
      rake "server:$type:start:ies[$name]"
    fi
    sleep 0.2
  done
}

function iwfm_is_startup_completed() {
  local server="$1"
  local name="$2"
  grep 'startup completed' "$(iwfm_log_file "$server" "$name")" && \
    iwfm_is_running "$server" "$name"
}

function iwfm_log_file() {
  local server=$1
  local name=$2
  local type; type=$(iwfm_type_by_name "$name")
  if test "$type" == injixo ; then
    echo ~/Library/Logs/iwfm/injixo/"$server"."$name".log
  else
    echo ~/Library/Logs/iwfm/"$type"/"$server".log
  fi
}

function run_iwfm_stop() {
  local name=$1
  local type; type=$(iwfm_type_by_name "$name")
  rake "server:$type:stop[$name]"
}

function iwfm_all_injixo_tenants() {
  local injixo_iwfm_config_dir="$HOME/.wine/drive_c/iwfmcommon/injixo/"
  find "$injixo_iwfm_config_dir" -name tcpip.\* | sed -e 's/^.*\.\([[:digit:]]\)$/\1/g' | tr '\n' ' '
}

function iwfm_type_by_name() {
  case "$1" in
    306*) echo classic306 ;;
    307*) echo classic ;;
    *) echo injixo ;;
  esac
}

function iwfm_is_running() {
  local server=${1-iescon}
  local tenant=$2
  local type; type=$(iwfm_type_by_name "$name")
  test ! "$type" = injixo && tenant=
  pgrep -f "wine\.bin $server .*$type/isps\.$tenant\.?cfg"
}

function run_iwfm_status() {
  print_iwfm_status_line iwfm ies ihs port
  for name in 306 307 $(iwfm_all_injixo_tenants) ; do
    local ies; ies=$(updown iwfm_is_running iescon "$name")
    local ihs; ihs=$(updown iwfm_is_running ihscon "$name")
    local ies_port; ies_port=$(iwfm_port "$name")
    print_iwfm_status_line "$name" "$ies" "$ihs" "$ies_port"
  done
}

function print_iwfm_status_line() {
  printf "%6s - %4s %4s %5s\n" "$@"
}

function iwfm_port() {
  name="$1"
  case "$name" in
    306) cat "$HOME/.wine/drive_c/iwfmcommon/classic306/tcpip" ;;
    307) cat "$HOME/.wine/drive_c/iwfmcommon/classic/tcpip" ;;
    *) cat "$HOME/.wine/drive_c/iwfmcommon/injixo/tcpip.$name" ;;
  esac
}

function run_iwfm_list() {
  echo 306 307 "$(iwfm_all_injixo_tenants)"
}

function run_iwfm_log() {
  $I_LOG_CMD "$(iwfm_log_file iescon "$1")"
}

function run_iwfm_edit_config() {
  local name="$1"
  local isps_cfg; isps_cfg="$(iwfm_isps_cfg "$name")"
  "$I_EDITOR" "$isps_cfg"
}

function iwfm_isps_cfg() {
  local name="$1"
  case "$name" in
    306) echo "$HOME/.wine/drive_c/iwfmcommon/classic306/isps.cfg" ;;
    307) echo "$HOME/.wine/drive_c/iwfmcommon/classic/isps.cfg" ;;
    *) echo "$HOME/.wine/drive_c/iwfmcommon/injixo/isps.2.cfg" ;;
  esac
}

function run_iwfm_help() {
  cat <<EOF
$0 iwfm CMD

  reset IWFM -- clear database and restart iWFM-wine iWFM
  start IWFM -- start iWFM-wine iWFM
  stop IWFM  -- stop iWFM-wine iWFM
  status     -- status of all iWFM-wine iWFMs
  list       -- list iWFM-wine iWFMs
  log IWFM   -- display iWFM logfile
  cfg IWFM   -- edit isps.cfg
  help       -- this help message
EOF
}
