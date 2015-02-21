#! /bin/bash

UPDATE_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$UPDATE_HERE/../lib.sh"

read_config

function update_feature() {
  local feature=$1
  local max_length=${2-0}

  local feature_dir="$PROJECTS_DIR/$feature"
  if test ! -d "$feature_dir/.git" ; then
    echo "Not installed feature '$feature'"
    exit 1
  fi
  local branch=$(git -C "$feature_dir" symbolic-ref -q --short HEAD 2>/dev/null)
  printf "%-${max_length}s - " "$feature"
  if test "$branch" = master ; then
    local changed=$(git -C "$feature_dir" status --porcelain --untracked-files=no)
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
}

function update_features() {
  local features=$(installed_features)
  local max_length=0
  for feature in $features ; do
    max_length=$((${#feature} > max_length ? ${#feature} : max_length))
  done

  for feature in $features ; do
    update_feature "$feature" "$max_length"
  done
}

function run_update() {
  if test $# -eq 0 ; then
    update_features
  else
    update_feature "$*"
  fi
}
