#!/bin/bash
################################################################################
# Script: test-hybrid-aoscx.sh
# Description: Test script for Hybrid VRF creation (AOS-CX mode)
################################################################################

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║         TESTE: Script Híbrido - Modo AOS-CX REST API                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Load environment if exists
if [ -f .env ]; then
    # shellcheck disable=SC1091
source .env
fi

# Check if switch is configured
if [ -z "${AOSCX_SWITCH_IP}" ]; then
    echo "⚠️  AOSCX_SWITCH_IP não configurado no .env"
    echo "   Usando valor padrão: cx10000.local"
    AOSCX_SWITCH="cx10000.local"
else
    AOSCX_SWITCH="${AOSCX_SWITCH_IP}"
fi

echo "📋 Configuração:"
echo "  Modo: aos-cx"
echo "  Switch: ${AOSCX_SWITCH}"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TESTE 1: DRY RUN - Validação sem criar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

./create-vrf-hybrid.sh \
  --mode aos-cx \
  --switch "${AOSCX_SWITCH}" \
  --name TEST-HYBRID-AOSCX-01 \
  --rt-mode import \
  --rt-af evpn \
  --rt-community "65000:999" \
  --bgp-bestpath \
  --bgp-fast-fallover \
  --bgp-log-neighbor-changes \
  --max-sessions 10000 \
  --max-cps 1000 \
  --description "Teste do script híbrido - modo AOS-CX" \
  --dry-run

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Teste DRY RUN concluído!"
echo ""
echo "⚠️  NOTA: Para criar VRF real no switch, você precisa:"
echo "   1. Configurar credenciais AOS-CX no .env"
echo "   2. Ter acesso ao switch"
echo "   3. Remover --dry-run"
echo ""
echo "Exemplo:"
echo ""
echo "./create-vrf-hybrid.sh \\"
echo "  --mode aos-cx \\"
echo "  --switch \"${AOSCX_SWITCH}\" \\"
echo "  --name TEST-HYBRID-AOSCX-01 \\"
echo "  --rt-mode import \\"
echo "  --rt-af evpn \\"
echo "  --bgp-bestpath \\"
echo "  --max-sessions 10000"
echo ""
