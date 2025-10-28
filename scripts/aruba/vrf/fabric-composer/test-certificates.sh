#!/bin/bash
################################################################################
# Script: extract-afc-fqdn.sh
# Description: Extrai e exibe o FQDN (CN) do certificado do servidor AFC
################################################################################

set -euo pipefail

# Configuração
AFC_HOST="${AFC_HOST:-172.31.8.99}"
AFC_PORT="${AFC_PORT:-443}"

echo "=== EXTRAÇÃO DE FQDN DO CERTIFICADO AFC ==="
echo ""
echo "Target: ${AFC_HOST}:${AFC_PORT}"
echo ""

echo "Extraindo CN (Common Name) do certificado:"
cert_cn=""
cert_cn=$(
  timeout 5 openssl s_client -servername "${AFC_HOST}" -connect "${AFC_HOST}:${AFC_PORT}" </dev/null 2>/dev/null |
    awk '/BEGIN CERTIFICATE/{flag=1} flag{print} /END CERTIFICATE/{flag=0; exit}' |
    openssl x509 -noout -subject -nameopt RFC2253 2>/dev/null |
    sed -E 's#.*CN=([^,/]+).*#\1#'
) || true

if [[ -n "${cert_cn}" ]]; then
  echo "   ✓ CN detectado: ${cert_cn}"
else
  echo "   ✗ Falha ao extrair CN"
fi

echo "======================"
echo "Resultado original do comando:"
echo "openssl s_client -servername ${AFC_HOST} -connect ${AFC_HOST}:${AFC_PORT}"
echo ""
openssl s_client -servername "${AFC_HOST}" -connect "${AFC_HOST}":"${AFC_PORT}"
