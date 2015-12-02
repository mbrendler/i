#! /bin/bash

INSTALLED_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$INSTALLED_HERE/../lib.sh"

read_config

function doc_list() {
  echo "  list                     -- list installed features"
}

function run_list() {
  installed_features
}
