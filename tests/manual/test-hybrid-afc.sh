#!/bin/bash
################################################################################
# Script: test-hybrid-afc.sh
# Description: Test script for Hybrid VRF creation (Fabric Composer mode)
################################################################################

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║      TESTE: Script Híbrido - Modo Fabric Composer                       ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Load environment
if [ ! -f .env ]; then
    echo "❌ Arquivo .env não encontrado!"
    exit 1
fi

# shellcheck disable=SC1091
source .env

echo "📋 Configuração:"
echo "  Modo: fabric-composer"
echo "  Fabric Composer: ${FABRIC_COMPOSER_IP}"
echo "  Fabric: default"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TESTE 1: DRY RUN - Validação sem criar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./create-vrf-hybrid.sh \
  --mode fabric-composer \
  --env-file .env \
  --name TEST-HYBRID-AFC-01 \
  --fabric default \
  --rd 65000:999 \
  --rt-import "65000:999" \
  --rt-export "65000:999" \
  --af ipv4 \
  --description "Teste do script híbrido - modo AFC" \
  --dry-run

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Teste DRY RUN concluído!"
echo ""
echo "Para criar VRF real, remova --dry-run:"
echo ""
echo "./create-vrf-hybrid.sh \\"
echo "  --mode fabric-composer \\"
echo "  --env-file .env \\"
echo "  --name TEST-HYBRID-AFC-01 \\"
echo "  --fabric default \\"
echo "  --rd 65000:999 \\"
echo "  --rt-import \"65000:999\" \\"
echo "  --rt-export \"65000:999\" \\"
echo "  --af ipv4 \\"
echo "  --description \"Teste do script híbrido - modo AFC\""
echo ""
