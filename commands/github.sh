
function doc_github() {
  echo "  github FEATURE    -- open browser with feature on github"
}

function run_github() {
  local feature=$1
  if test -n "$feature" ; then
    open "$I_GITHUB_BASE_URL/$feature"
  else
    >&2 echo "Usage: $0 github FEATURE"
  fi
}
