
function doc--new() {
  echo new PROJECT -- create new project
}

function run--new() {
  local name=$1
  local path="$PROJECTS_DIR/$name"
  mkdir -p "$path"
  git init "$path"
}
