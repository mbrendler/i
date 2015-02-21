
function read_config() {
  I_CONFIG_FILE=${I_CONFIG_FILE-"$HOME/.i"}
  test -e "$I_CONFIG_FILE" && source "$I_CONFIG_FILE"
  PROJECTS_DIR=${PROJECTS_DIR-"$HOME/work"}
}

function installed_features(){
  for feature_dir in "$PROJECTS_DIR"/* ; do
    if test -d "$feature_dir/.git" ; then
      basename "$feature_dir"
    fi
  done
}