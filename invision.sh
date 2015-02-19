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
  update [FEATURE]  -- update InVision project
EOF
}

function update_features(){
  max_width=0
  for feature_dir in "$INVISION_WORK"/* ; do
    if test -d "$feature_dir" ; then
      current_length=$(basename "$feature_dir" | wc -c)
      max_width=$(($current_length > $max_width ? $current_length : $max_width))
    fi
  done

  for feature_dir in "$INVISION_WORK"/* ; do
    if test -d "$feature_dir" ; then
      name=$(basename "$feature_dir")
    fi
  done

  for feature_dir in "$INVISION_WORK"/* ; do
    if test -d "$feature_dir" ; then
      branch=$(git -C "$feature_dir" symbolic-ref -q --short HEAD 2>/dev/null)
      name=$(basename "$feature_dir")
      if test $? -eq 0 ; then
        printf "%-${max_width}s - " "$name"
        if test "$branch" = master ; then
          changed=$(git -C "$feature_dir" status --porcelain)
          if test -z "$changed" ; then
            git -C "$feature_dir" fetch > /dev/null
            change_count=$(git -C "$feature_dir" rev-list HEAD...origin/master --count)
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
      fi
    fi
  done
}

case "$CMD" in
help)
  prog_help
;;

install)
;;

update)
  update_features
;;

*)
  prog_help
  exit 1
;;
esac
