#!/bin/bash
# Diagnostico AFC: mostrar somente o teste que deu certo

set -euo pipefail

AFC_HOST="172.31.8.99"
AFC_USER="admin"
AFC_PASS="Aruba123!"

extract_token() {
  local body="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r '.result // .token // .access_token // empty' <<<"$body"
  else
    # Tentativa simples sem jq
    sed -n 's/.*"result"[[:space:]]*:[[:space:]]*"\([^"]\+\)".*/\1/p' <<<"$body"
  fi
}

run_test() {
  local num="$1"
  shift
  local title="$1"
  shift
  local response http_code body token
  response=$("$@" -w $'\n%{http_code}' 2>&1 || true)
  http_code="$(printf "%s" "${response}" | tail -n1)"
  body="$(printf "%s" "${response}" | sed '$d')"
  if [[ "${http_code}" == "200" ]]; then
    token="$(extract_token "${body}")"
    echo "TESTE_OK=${num}"
    echo "TITULO=${title}"
    echo "HTTP_CODE=${http_code}"
    echo "RESPONSE=${body}"
    [[ -n "${token}" ]] && echo "TOKEN=${token}"
    exit 0
  fi
}

# 1) Doc oficial: POST X-Auth-* sem barra final
run_test 1 "POST X-Auth headers (sem barra)" \
  curl -sk -X POST \
  -H "X-Auth-Username: ${AFC_USER}" \
  -H "X-Auth-Password: ${AFC_PASS}" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://${AFC_HOST}/api/v1/auth/token"

# 2) Doc oficial: POST X-Auth-* com barra final
run_test 2 "POST X-Auth headers (com barra)" \
  curl -sk -X POST \
  -H "X-Auth-Username: ${AFC_USER}" \
  -H "X-Auth-Password: ${AFC_PASS}" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://${AFC_HOST}/api/v1/auth/token/"

# 3) Doc oficial + bypass total de proxy
run_test 3 "POST X-Auth headers (noproxy)" \
  curl -sk --noproxy '*' -X POST \
  -H "X-Auth-Username: ${AFC_USER}" \
  -H "X-Auth-Password: ${AFC_PASS}" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://${AFC_HOST}/api/v1/auth/token"

# 4) Basic Auth (legado)
run_test 4 "POST Basic Auth" \
  curl -sk -X POST \
  -u "${AFC_USER}:${AFC_PASS}" \
  -H "Content-Type: application/json" \
  "https://${AFC_HOST}/api/v1/auth/token"

# 5) Credenciais no corpo JSON (legado)
run_test 5 "POST JSON com credenciais no corpo" \
  curl -sk -X POST \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"${AFC_USER}\",\"password\":\"${AFC_PASS}\"}" \
  "https://${AFC_HOST}/api/v1/auth/token"

# 6) GET Basic Auth (muito legado)
run_test 6 "GET Basic Auth" \
  curl -sk -X GET \
  -u "${AFC_USER}:${AFC_PASS}" \
  "https://${AFC_HOST}/api/v1/auth/token"

echo "Nenhum teste retornou HTTP 200"
exit 2
