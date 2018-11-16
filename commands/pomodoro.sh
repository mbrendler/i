#! /bin/bash

I_POMODORO_FILE="${I_POMODORO_FILE:-/tmp/pomodoro.$(id -u)}"
I_POMODORO_DEFAULT_MINUTES=${I_POMODORO_DEFAULT_MINUTES:-25}
I_POMODORO_COMPLETE=${I_POMODORO_COMPLETE:-'osascript -e "display notification \"complete\" with title \"pomodoro\""'}

function doc--pomodoro() {
  echo 'pomodoro [up|halt|status] -- start pomodoro'
}

function run--pomodoro() {
  local commands=$"
halt
up
status
"
  local cmd;cmd="$(complete-by-list command "$commands" "${1:-status}")"

  case "$cmd" in
    halt) pomodoro-stop ;;
    up) pomodoro-start "${2-$I_POMODORO_DEFAULT_MINUTES}";;
    status) pomodoro-status "${2-}";;
  esac
}

function pomodoro-start() {
  local minutes="$1"
  if ! pomodoro-is-running ; then
    nohup bash -c "echo \$\$ ; echo $minutes ; sleep $((minutes * 60)) ; $I_POMODORO_COMPLETE" > "$I_POMODORO_FILE" 2> "$I_POMODORO_FILE.err" &
  else
    echo pomodoro is already running
    pomodoro-status
    exit 1
  fi
}

function pomodoro-stop() {
  kill "$(pomodoro-previous-pid)"
}

function pomodoro-status() {
  if pomodoro-is-running ; then
    local seconds;seconds="$(pomodoro-current-time)"
    local min;min=$((-1 * seconds / 60))
    if [ "${1}" = "-s" ] ; then
      echo "$min"
    else
      local s;s=$((-1 * seconds))
      while ((s >= 60)) ; do
        s=$((s - 60))
      done
      echo pomodoro time: "${min}min ${s}s"
    fi
  else
    if [ "${1}" = "-s" ] ; then
      echo -
    else
      echo "last pomodoro finished: $(pomodoro-format-time $(pomodoro-finished-at))"
    fi
  fi
}

function pomodoro-format-time() {
  /bin/date -r "$1" '+%F %H:%M:%S'
}

function pomodoro-previous-pid() {
  head -n1 "$I_POMODORO_FILE" 2>/dev/null || true
}

function pomodoro-previous-minutes() {
  tail -n1 "$I_POMODORO_FILE" 2>/dev/null || true
}

function pomodoro-current-time() {
  local started_at;started_at="$(pomodoro-started-at)"
  local now;now="$(date +%s)"
  local duration;duration="$(pomodoro-previous-minutes)"
  echo $((now - started_at - 60 * duration))
}

function pomodoro-started-at() {
  stat -c %Y "$I_POMODORO_FILE"
}

function pomodoro-finished-at() {
  local started_at;started_at="$(pomodoro-started-at)"
  local duration;duration="$(pomodoro-previous-minutes)"
  echo $((started_at + duration * 60))
}

function pomodoro-is-running() {
  local pid;pid="$(pomodoro-previous-pid)"
  if [ -n "$pid" ] && ps -p "$pid" > /dev/null ; then
    if [ "$(pomodoro-current-time)" -le 0 ] ; then
      return 0
    fi
  fi
  return 1
}
