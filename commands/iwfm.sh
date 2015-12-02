#! /bin/bash

function doc_iwfm() {
  echo '  iwfm CMD                 -- work with iWFM-wine'
}

function run_iwfm() {
  local name=${2-}
  log pushd "$PROJECTS_DIR/iwfm-wine"
  case "$1" in
    r*) run_iwfm_reset "$name" ;;
    star*) run_iwfm_start "$name" ;;
    sto*) run_iwfm_stop "$name" ;;
    stat*) run_iwfm_status ;;
    l*) run_iwfm_list ;;
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
  if log iwfm_is_running iescon "$name" > /dev/null ; then
    echo "iWFM $name is already running"
    return
  fi
  until log iwfm_startup_is_completed "$name" > /dev/null && log iwfm_is_running iescon "$name" > /dev/null ; do
    if ! log iwfm_is_running iescon "$name" > /dev/null ; then
      rake "server:$type:start:ies[$name]"
    fi
    sleep 0.2
  done
}

function iwfm_startup_is_completed() {
  grep 'startup completed' "$(iwfm_log_file "$1")"
}

function iwfm_log_file() {
  local name=$1
  local type
  type=$(iwfm_type_by_name "$name")
  if test "$type" == injixo ; then
    echo ~/Library/Logs/iwfm/injixo/iescon."$name".log
  else
    echo ~/Library/Logs/iwfm/"$type"/iescon.log
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
  local type
  type=$(iwfm_type_by_name "$name")
  test ! "$type" = injixo && tenant=
  pgrep -f "wine\.bin $server .*$type/isps\.$tenant\.?cfg"
}

function run_iwfm_status() {
  printf "%6s - %3s %3s\n" iwfm ies ihs
  for name in 306 307 $(iwfm_all_injixo_tenants) ; do
    local ies
    ies=$(yesno iwfm_is_running iescon "$name")
    local ihs
    ihs=$(yesno iwfm_is_running ihscon "$name")
    printf "%6s - %3s %3s\n" "$name" "$ies" "$ihs"
  done
}

function run_iwfm_list() {
  echo 306 307 "$(iwfm_all_injixo_tenants)"
}

function run_iwfm_help() {
  echo "$0 iwfm CMD [OPTIONS]"
  echo
  echo '  reset IWFM -- clear database and restart iWFM-wine iWFM'
  echo '  start IWFM -- start iWFM-wine iWFM'
  echo '  stop IWFM  -- stop iWFM-wine iWFM'
  echo '  status     -- status of all iWFM-wine iWFMs'
  echo '  list       -- list iWFM-wine iWFMs'
  echo "  help       -- this help message"
}
