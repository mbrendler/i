
function doc--quay() {
  echo 'quay [FEATURE] -- open feature in quay.io'
}

function run--quay() {
  local feature;feature="$(get_feature_name quay "${1-}")"
  local url="https://quay.io/repository/${QUAY_NAMESPACE}/${feature}"
  i-browser "$url"
}
