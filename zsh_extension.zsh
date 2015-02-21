# ADD this to your ~/.zshrc to use 'i cd $feature'.

function i {
  if test "$1" = cd ; then
    shift
    cd "$(command i dir "$@")"
  else
    command i "$@"
  fi
}
