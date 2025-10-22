#!/bin/bash
################################################################################
# Script: debug-morpheus-env.sh
# Description: Collect environment diagnostics for Morpheus tasks
################################################################################

set -euo pipefail

# AFC target and creds (can be overridden via env: AFC_HOST, AFC_USER, AFC_PASS)
AFC_HOST="${AFC_HOST:-172.31.8.99}"
AFC_USER="${AFC_USER:-admin}"
AFC_PASS="${AFC_PASS:-Aruba123!}"
echo "[info] AFC target: ${AFC_HOST} | user: ${AFC_USER} | pass: (hidden)"

echo "=== MORPHEUS ENVIRONMENT DIAGNOSTICS ==="
echo ""

echo "1. Usuário e hostname:"
whoami
hostname
id

echo ""
echo "2. Curl version e features:"
curl --version

echo ""
echo "3. Variáveis de ambiente (filtrado):"
env | grep -i proxy || echo "No proxy vars"
env | grep -i http || echo "No HTTP vars"
env | grep -i morpheus | head -10 || echo "No Morpheus vars"

echo ""
echo "4. Roteamento de rede:"
ip route 2>/dev/null || route -n 2>/dev/null || echo "Cannot check routes"

echo ""
echo "5. DNS resolution do AFC:"
host "$AFC_HOST" 2>/dev/null || nslookup "$AFC_HOST" 2>/dev/null || echo "Cannot resolve"

echo ""
echo "6. Conectividade com AFC (ping):"
ping -c 2 -W 2 "$AFC_HOST" 2>&1 || echo "Ping failed or not permitted"

echo ""
echo "7. Conectividade com AFC porta 443:"
timeout 3 bash -c "cat < /dev/null > /dev/tcp/${AFC_HOST}/443" 2>&1 && echo "✓ Port 443 is reachable" || echo "✗ Port 443 unreachable"

echo ""
echo "8. Testar TLS/SSL handshake:"
timeout 3 openssl s_client -connect "${AFC_HOST}:443" -showcerts </dev/null 2>&1 | head -30 || echo "SSL handshake failed"

echo ""
echo "9. Curl test SIMPLES (sem auth, só ver resposta):"
curl -sk -v -X GET "https://${AFC_HOST}/" 2>&1 | head -50

echo ""
echo "10. Curl test AUTH (mesmo do test-afc-auth.sh):"
curl -skv -w "\nHTTP_CODE=%{http_code}\n" -X POST \
  -H "X-Auth-Username: ${AFC_USER}" \
  -H "X-Auth-Password: ${AFC_PASS}" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://${AFC_HOST}/api/v1/auth/token" 2>&1 | head -80

echo ""
echo "10b. Curl test AUTH usando CN do certificado (vhost) com --resolve:"
# Extrair o CN do certificado do servidor (primeiro certificado apresentado)
cert_cn="$(
  timeout 3 openssl s_client -servername "${AFC_HOST}" -connect "${AFC_HOST}:443" </dev/null 2>/dev/null |
    awk '/BEGIN CERTIFICATE/{flag=1} flag{print} /END CERTIFICATE/{flag=0; exit}' |
    openssl x509 -noout -subject -nameopt RFC2253 2>/dev/null |
    sed -E 's#.*CN=([^,/]+).*#\1#'
)"

if [[ -n "${cert_cn}" && "${cert_cn}" != "${AFC_HOST}" ]]; then
  echo "[info] Detected cert CN: ${cert_cn} — testing with virtual host routing"
  curl -skv --resolve "${cert_cn}:443:${AFC_HOST}" -w "\nHTTP_CODE=%{http_code}\n" -X POST \
    -H "X-Auth-Username: ${AFC_USER}" \
    -H "X-Auth-Password: ${AFC_PASS}" \
    -H "Content-Type: application/json" \
    -d '{"token-lifetime":30}' \
    "https://${cert_cn}/api/v1/auth/token" 2>&1 | head -80
else
  echo "[warn] Could not determine a certificate CN different from target; skipping vhost test"
fi

echo ""
echo "=== END DIAGNOSTICS ==="
