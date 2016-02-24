#! /bin/bash

UPDATE_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$UPDATE_HERE/../lib.sh"

read_config

function doc_update() {
  echo "  update [FEATURE]         -- update project"
}

function update_post_pull() {
  if test -f 'Gemfile' ; then
    log bundle install
  fi
  if test -d 'db' ; then
    log bundle exec rake db:migrate
    log git reset --hard
  fi

  if test -f 'package.json' ; then
    log npm install
  fi
  if test -f 'bower' ; then
    log bower install
  fi
}

function update_feature() {
  local feature=$1
  local max_length=${2-0}

  local feature_dir="$PROJECTS_DIR/$feature"
  if test ! -d "$feature_dir/.git" ; then
    echo "Not installed feature '$feature'"
    exit 1
  fi

  log_message update "$feature"
  log pushd "$feature_dir"
  local branch=$(git symbolic-ref -q --short HEAD 2>/dev/null)
  printf "%-${max_length}s - " "$feature"
  if test "$branch" = master ; then
    local changed=$(git status --porcelain --untracked-files=no)
    if test -z "$changed" ; then
      log git fetch
      let change_count=$(git rev-list HEAD...origin/master --count)
      if test $change_count -ne 0 ; then
        log git pull
        update_post_pull
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
  log popd
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

function run--update() {
  if test $# -eq 0 || test -z "$1" ; then
    update_features
  else
    update_feature "$*"
  fi
}
