
function doc_github() {
  echo "  github [FEATURE]  -- open browser with feature on github"
}

function run_github() {
  local feature="$(get_feature_name github "$1")"
  test -n "$feature" && open "$I_GITHUB_BASE_URL/$feature"
}
