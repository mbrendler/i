#! /bin/bash

UPDATE_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$UPDATE_HERE/../lib.sh"

read_config

function update_features(){
  local features=$(installed_features)
  local max_length=0
  for feature in $features ; do
    max_length=$((${#feature} > max_length ? ${#feature} : max_length))
  done

  for feature in $features ; do
    local feature_dir="$PROJECTS_DIR/$feature"
    local branch=$(git -C "$feature_dir" symbolic-ref -q --short HEAD 2>/dev/null)
    printf "%-${max_length}s - " "$feature"
    if test "$branch" = master ; then
      local changed=$(git -C "$feature_dir" status --porcelain)
      if test -z "$changed" ; then
        log git -C "$feature_dir" fetch
        let change_count=$(git -C "$feature_dir" rev-list HEAD...origin/master --count)
        if test $change_count -ne 0 ; then
          log git -C "$feature_dir" pull
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

function run_update(){
  update_features
}
