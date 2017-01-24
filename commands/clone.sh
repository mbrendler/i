
function doc--clone() {
  echo clone PROJECT -- clone project
}

function run--clone() {
  local name=$1
  git clone "$I_GITHUB_BASE_URL/$name" "$PROJECTS_DIR/$name"
}
