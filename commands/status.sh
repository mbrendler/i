#! /bin/bash

function doc--status() {
  echo 'status -- show status information'
}

function run--status() {
  i iwfm status

  echo
  (status-simple nginx ;
   status-simple postgres ;
   status-simple redis) | \
     status-add-heading process,status | \
     pretty '"%10s - %6s\n", $1, $2'

  echo
  status-feature-ports | \
    status-feature-insert-status | \
    status-add-heading feature,status,port| \
    pretty '"%18s - %6s %5s\n", $1, $2, $3'
}

function status-add-heading() {
  echo "$@"
  cat
}

function status-simple() {
  echo "$1,$(updown pgrep "$1")"
}

function status-feature-insert-status() {
  local netstat_anv;netstat_anv="$(netstat -anv)"
  while read -r x ; do
    local name;name="$(echo "$x" | cut -d, -f1)"
    local port;port="$(echo "$x" | cut -d, -f2)"
    echo "$name,$(echo "$netstat_anv" | updown grep "\.$port .*LISTEN"),$port"
  done
}

function status-feature-ports() {
  sed -nE 's/^([^:]+):.*-p ([0-9]+).*$/\1,\2/p' "$PROJECTS_DIR/grabbel/Procfile"
}
