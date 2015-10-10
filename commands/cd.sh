
function doc_cd() {
  echo '  cd FEATURE        -- switch to feature directory'
}

function run_cd() {
  cat << EOF
# To use this, add the following to your ~/.zshrc:

function i {
  if test "\$1" = cd ; then
    shift
    cd "\$(command i dir "\$@")"
  else
    command i "\$@"
  fi
}
EOF
}
