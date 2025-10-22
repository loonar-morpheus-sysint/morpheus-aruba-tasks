#!/bin/bash
################################################################################
# Script: debug-morpheus-env.sh
# Description: Collect environment diagnostics for Morpheus tasks
################################################################################

set -euo pipefail

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
host 172.31.8.99 2>/dev/null || nslookup 172.31.8.99 2>/dev/null || echo "Cannot resolve"

echo ""
echo "6. Conectividade com AFC (ping):"
ping -c 2 -W 2 172.31.8.99 2>&1 || echo "Ping failed or not permitted"

echo ""
echo "7. Conectividade com AFC porta 443:"
timeout 3 bash -c "cat < /dev/null > /dev/tcp/172.31.8.99/443" 2>&1 && echo "✓ Port 443 is reachable" || echo "✗ Port 443 unreachable"

echo ""
echo "8. Testar TLS/SSL handshake:"
timeout 3 openssl s_client -connect 172.31.8.99:443 -showcerts </dev/null 2>&1 | head -30 || echo "SSL handshake failed"

echo ""
echo "9. Curl test SIMPLES (sem auth, só ver resposta):"
curl -sk -v -X GET "https://172.31.8.99/" 2>&1 | head -50

echo ""
echo "10. Curl test AUTH (mesmo do test-afc-auth.sh):"
curl -skv -w "\nHTTP_CODE=%{http_code}\n" -X POST \
  -H "X-Auth-Username: admin" \
  -H "X-Auth-Password: Aruba123!" \
  -H "Content-Type: application/json" \
  -d '{"token-lifetime":30}' \
  "https://172.31.8.99/api/v1/auth/token" 2>&1 | head -80

echo ""
echo "=== END DIAGNOSTICS ==="
