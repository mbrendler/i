#! /bin/bash

INSTALLED_HERE="$(python -c "import os; print(os.path.dirname(os.path.realpath('$BASH_SOURCE')))")"
source "$INSTALLED_HERE/../lib.sh"

read_config

function run_installed(){
  installed_features
}
