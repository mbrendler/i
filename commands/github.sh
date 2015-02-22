
function doc_github() {
  echo "  github [FEATURE]  -- open browser with feature on github"
}

function run_github() {
  local feature="$(get_feature_name github "$1")"
  if test -n "$feature" ; then
    open "$I_GITHUB_BASE_URL/$feature"
    sleep 0.1
    log osascript "$HERE/go_to_window.scpt"
  fi
}
