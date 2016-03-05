#! /usr/bin/env zsh

run_completion() {
  local CURRENT=$1
  shift
  local words=()
  for i in {1..$#} ; words[$i]=$@[$i]
  >&2 echo "'$words'"
  eval "$(cat zsh-completion/_i)"
}

_values() {
  shift
  echo " $@ "| sed -E 's/\[[^]]*\]//g'
}

_describe() {
  eval echo \" \$$2 \"
}

_files() {
  echo ' ---files--- '
}

assert() {
  local content="$(cat)"
  for x in $@ ; do
    if ! grep " $x " <(echo $content) > /dev/null ; then
      echo bad \'$x\' not in \'$content\'
      echo expected: \'$@\'
      exit 1
    fi
  done
  echo ok
}

assert-empty() {
  local content="$(cat)"
  if [ -n "$content" ] ; then
    echo bad \'$content\' should be empty
    exit 1
  fi
  echo ok
}

is-extra-command-installed() {
  i help | grep "^  $1" > /dev/null
}

run_completion 2 i | assert cd github help iwfm
run_completion 2 i '' | assert cd github help iwfm
run_completion 2 i c | assert cd github help iwfm
run_completion 2 i c hallo | assert cd github help iwfm
run_completion 3 i cd '' | assert Me iwfm-api iwfm-ruby iwfm-test iwfm
run_completion 2 i i | assert cd github help iwfm
run_completion 3 i iwfm '' | assert reset start stop status help
run_completion 3 i status '' | assert-empty
run_completion 3 i st '' | assert-empty

if is-extra-command-installed build ; then
  run_completion 2 i b | assert build cd github help iwfm
  run_completion 4 i build fail '' | assert frankenstein injixo opti xlink
  run_completion 5 i build fail frank '' | assert ies.log security.log
fi

if is-extra-command-installed crawl ; then
  run_completion 3 i c '' | assert-empty
  run_completion 3 i crawl '' | assert -s -l -r -c -u -p session-token \
                                       tenants iwfm-versions query run
  run_completion 3 i crawl - | assert -s -l -r -c -u -p session-token \
                                      tenants iwfm-versions query run
  run_completion 4 i crawl -l '' | assert -s -l -r -c -u -p session-token \
                                          tenants iwfm-versions query run
  run_completion 4 i crawl -u '' | assert-empty
  run_completion 5 i crawl -u hehe '' | assert -s -l -r -c -u -p session-token \
                                               tenants iwfm-versions query run
  run_completion 4 i crawl run '' | assert ---files---
  run_completion 6 i crawl -u hehe run '' | assert ---files---
fi
