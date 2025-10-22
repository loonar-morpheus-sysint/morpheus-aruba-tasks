#!/bin/bash
# Debug script: compare curl verbose output

set -euo pipefail

AFC_HOST="172.31.8.99"
AFC_USER="admin"
AFC_PASS="Aruba123!"

echo "=== TEST 1: Curl verbose (como test-afc-auth.sh) ==="
curl -skv -w "\n%{http_code}\n" -X POST \
  -H "X-Auth-Username: ${AFC_USER}" \
  -H "X-Auth-Password: ${AFC_PASS}" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://${AFC_HOST}/api/v1/auth/token" 2>&1 | head -50

echo ""
echo "=== TEST 2: Verificar se NGINX está realmente respondendo ==="
curl -skI "https://${AFC_HOST}/" 2>&1 | grep -i server || echo "No Server header"

echo ""
echo "=== TEST 3: Testar endpoint de health (se existir) ==="
curl -sk "https://${AFC_HOST}/api/v1/health" 2>&1 | head -10 || echo "Health endpoint não existe"

echo ""
echo "=== TEST 4: Resolver DNS e conectividade ==="
host "${AFC_HOST}" 2>&1 || echo "DNS resolution failed"
ping -c 2 "${AFC_HOST}" 2>&1 || echo "Ping failed"

echo ""
echo "=== TEST 5: Verificar se porta 443 está aberta ==="
timeout 3 bash -c "cat < /dev/null > /dev/tcp/${AFC_HOST}/443" 2>&1 && echo "Port 443 is open" || echo "Port 443 is closed or filtered"
