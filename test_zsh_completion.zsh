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

_normal() {
  echo ' ---normal--- $CURRENT $words'
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

run_completion 2 i | assert cd github help
run_completion 2 i '' | assert cd github help
run_completion 2 i c | assert cd github help
run_completion 2 i c hallo | assert cd github help
run_completion 3 i cd '' | assert iwfm-api iwfm-ruby iwfm-test iwfm
run_completion 2 i i | assert cd github help
run_completion 3 i status '' | assert-empty
run_completion 3 i st '' | assert-empty
# run_completion 4 i run iwfm gi | assert git
run_completion 3 i pomodoro '' | assert up halt status
run_completion 3 i pomodoro 'h' | assert halt

if is-extra-command-installed build ; then
  run_completion 2 i b | assert build cd github help
  run_completion 3 i build '' | assert help get last-log
  run_completion 4 i build fail '' | assert frankenstein injixo opti xlink
  run_completion 5 i build fail frank '' | assert ies.log security.log
  run_completion 5 i build last-log -t '' | assert frankenstein injixo opti
  run_completion 6 i build last-log -t fr-ank '' | assert ies.log
  run_completion 6 i build last-log -t -s '' | assert-empty
  run_completion 7 i build last-log -t -s 10 '' | assert frankenstein injixo
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
