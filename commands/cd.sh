
function doc--cd() {
  echo 'cd FEATURE -- switch to feature directory'
}

function run--cd() {
  cat << EOF
# To use this, add the following to your ~/.zshrc:

i() {
  local arr=(\$@)
  for i in {1..\$#} ; do
    if test "\$@[i]" = 'cd' ; then
      arr[\$i]=dir
      cd "\$(command i \$arr)"
      return
    fi
  done
  command i "\$@"
}
EOF
}
