#! /bin/bash

I_POMODORO_FILE="${I_POMODORO_FILE:-/tmp/pomodoro.$(id -u)}"
I_POMODORO_DEFAULT_MINUTES=${I_POMODORO_DEFAULT_MINUTES:-25}

function doc--pomodoro() {
  echo 'pomodoro [up|halt|status] -- start pomodoro'
}

function run--pomodoro() {
  case "${1-}" in
    h*) pomodoro-stop ;;
    u*) pomodoro-start "${2-$I_POMODORO_DEFAULT_MINUTES}";;
    *) pomodoro-status "${2-}";;
  esac
}

function pomodoro-start() {
  local minutes="$1"
  if ! pomodoro-is-running ; then
    nohup bash -c "echo \$\$ ; echo $minutes ; sleep $((minutes * 60)) ; n complete pomodoro" > "$I_POMODORO_FILE" 2> "$I_POMODORO_FILE.err" &
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
      echo pomodoro is not running
    fi
  fi
}

function pomodoro-previous-pid() {
  head -n1 "$I_POMODORO_FILE" 2>/dev/null || true
}

function pomodoro-previous-minutes() {
  tail -n1 "$I_POMODORO_FILE" 2>/dev/null || true
}

function pomodoro-current-time() {
  local last_pomodoro_started;last_pomodoro_started="$(stat -c %Y "$I_POMODORO_FILE")"
  local current_time;current_time="$(date +%s)"
  echo $((current_time - last_pomodoro_started - 60 * $(pomodoro-previous-minutes)))
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
