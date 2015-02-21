
function installed_features(){
  for feature_dir in "$INVISION_WORK"/* ; do
    if test -d "$feature_dir/.git" ; then
      basename "$feature_dir"
    fi
  done
}
