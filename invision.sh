#! /bin/bash

CONFIG_FILE="$HOME/.invision"

test -e "$CONFIG_FILE" && source "$CONFIG_FILE"

INVISION_WORK="$HOME/work"  # TODO: configure in $CONFIG_FILE

SCRIPT=$0
CMD=$1

function prog_help(){
  cat << EOF
$SCRIPT CMD [OPTIONS]

  help              -- show help overview
  install [FEATURE] -- install InVision project
  installed         -- list installed features
  update [FEATURE]  -- update InVision project
EOF
}

function installed_features(){
  for feature_dir in "$INVISION_WORK"/* ; do
    if test -d "$feature_dir/.git" ; then
      basename "$feature_dir"
    fi
  done
}

function update_features(){
  local features=$(installed_features)
  local max_length=0
  for feature in $features ; do
    max_length=$((${#feature} > max_length ? ${#feature} : max_length))
  done

  for feature in $features ; do
    local feature_dir="$INVISION_WORK/$feature"
    local branch=$(git -C "$feature_dir" symbolic-ref -q --short HEAD 2>/dev/null)
    printf "%-${max_length}s - " "$feature"
    if test "$branch" = master ; then
      local changed=$(git -C "$feature_dir" status --porcelain)
      if test -z "$changed" ; then
        git -C "$feature_dir" fetch > /dev/null
        let change_count=$(git -C "$feature_dir" rev-list HEAD...origin/master --count)
        if test $change_count -ne 0 ; then
          git -C "$feature_dir" pull > /dev/null
          # TODO: prepare: bundle, migrate, ...
          # TODO: restart pow
          echo "updated ($change_count)"
        else
          echo "up-to-date"
        fi
      else
        echo "ignored - has changes"
      fi
    else
      echo "ignored - not on master"
    fi
  done
}

case "$CMD" in
help)
  prog_help
;;

install)
;;

installed)
  installed_features
;;

update)
  update_features
;;

*)
  prog_help
  exit 1
;;
esac
