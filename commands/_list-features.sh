#! /bin/bash

INSTALLED_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$INSTALLED_HERE/../lib.sh"

read_config

function doc__list-features() {
  echo "  _list-features           -- list installed features"
}

function run__list-features() {
  installed_features
}
