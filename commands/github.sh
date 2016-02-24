
function doc_github() {
  echo "  github [FEATURE] [ISSUE] -- open browser with feature on github"
}

function run--github() {
  local feature
  local issue
  if [[ "${1-}" =~ ^[0-9]+$ ]] ; then
    feature="$(get_feature_name github "")"
    issue="$1"
  else
    feature="$(get_feature_name github "${1-}")"
    issue="${2-}"
  fi
  if test -n "$feature" ; then
    if test -n "$issue" ; then
      open -g "$I_GITHUB_BASE_URL/$feature/issues/$issue"
    else
      open -g "$I_GITHUB_BASE_URL/$feature"
    fi
    sleep 0.1
    log osascript "$HERE/go_to_window.scpt"
  fi
}
