#! /bin/bash

function doc_iwfm() {
  echo '  iwfm CMD          -- work with iWFM-wine'
}

function run_iwfm() {
  case "$2" in
    306*)
      local iwfm=classic306
      local tenant=$iwfm
      local database=default
      local language=${3:-31}
      ;;
    307*)
      local iwfm=classic
      local tenant=$iwfm
      local database=default
      local language=${3:-31}
      ;;
    *)
      local iwfm=injixo
      local tenant=${3:-2}
      local database=$tenant
      local language=${4:-31}
      ;;
  esac
  log pushd "$PROJECTS_DIR/iwfm-wine"
  case "$1" in
    # reset
    r*)
      run_iwfm_reset "$iwfm" "$database" "$tenant" "$language"
      ;;
    # start
    star*)
      run_iwfm_start "$tenant"
      ;;
    # stop
    sto*)
      run_iwfm_stop "$tenant"
      ;;
    # status
    stat*)
      run_iwfm_status
      ;;
    # list
    l*)
      run_iwfm_list
      ;;
    *)
      run_iwfm_help
      ;;
  esac
  log popd
}

function run_iwfm_reset() {
  local iwfm=$1
  local database=$2
  local tenant=$3
  local language=$4
  run_iwfm_stop "$tenant"
  rake "server:$iwfm:db:reset[$database,$language]"
  # TODO: only start if was running
  run_iwfm_start "$tenant"
}

function run_iwfm_start() {
  local tenant=$1
  local running_script="$HOME/.wine/drive_c/iwfmcommon/running.sh"
  # TODO: use iwfm_is_running function
  until bash "$running_script" iescon "$tenant" > /dev/null ; do
    rake "server:$iwfm:start:ies[$tenant]"
    sleep 0.2
  done
}

function run_iwfm_stop() {
  local tenant=$1
  rake "server:$iwfm:stop[$tenant]"
}

function iwfm_all_injixo_tenants() {
  local injixo_iwfm_config_dir="$HOME/.wine/drive_c/iwfmcommon/injixo/"
  find "$injixo_iwfm_config_dir" -name tcpip.\* | sed -e 's/^.*\.\([[:digit:]]\)$/\1/g' | tr '\n' ' '
}

function iwfm_type_by_name() {
  case "$1" in
    306*)
      echo classic306
      ;;
    307*)
      echo classic
      ;;
    *)
      echo injixo
      ;;
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
