
function doc--github() {
  echo 'github [FEATURE] [ISSUE] -- open browser with feature on github'
}

function doc--github-options() {
  cat <<EOF
-p -- open pull-request with current branch
EOF
}

function run--github() {
  local feature
  local issue
  local branch
  local url="$I_GITHUB_BASE_URL"
  if [ "${1-}" = '-p' ] ; then
    branch="$(github-current-branch)"
    if [ "$branch" = master ] ; then
      >&2 echo can not create pull request with master branch
      exit 1
    fi
    shift
  fi
  if [[ "${1-}" =~ ^[0-9]+$ ]] ; then
    feature="$(get_feature_name github "")"
    issue="$1"
  else
    feature="$(get_feature_name github "${1-}")"
    issue="${2-}"
  fi
  if test -n "$feature" ; then
    url="$I_GITHUB_BASE_URL/$feature"
    test -n "$issue" && url="$url/issues/$issue"
    test -n "$branch" && url="${url}/compare/${branch}?expand=1"
  fi
  i-browser "$url"
}

function github-current-branch() {
  git rev-parse --abbrev-ref HEAD
}
