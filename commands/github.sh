
function doc--github() {
  echo 'github [FEATURE] [ISSUE] -- open browser with feature on github'
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
    local url="$I_GITHUB_BASE_URL/$feature"
    test -n "$issue" && url="$url/issues/$issue"
    i-browser "$url"
  fi
}
