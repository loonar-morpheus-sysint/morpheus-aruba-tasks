#!/bin/bash
################################################################################
# Script: example-vrf-workflow.sh
# Description: Example workflow showing VRF creation steps
################################################################################

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║            Exemplo de Workflow - Criação de VRF no AFC                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}PASSO 1:${NC} Verificar arquivo .env"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [ -f .env ]; then
    echo "✅ Arquivo .env encontrado"
    echo ""
    echo "Configuração atual:"
    grep -E "^FABRIC_COMPOSER_IP=" .env
    grep -E "^FABRIC_COMPOSER_USERNAME=" .env
    echo "FABRIC_COMPOSER_PASSWORD=****** (oculto por segurança)"
else
    echo "❌ Arquivo .env não encontrado!"
    echo "   Crie o arquivo .env com suas credenciais"
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}PASSO 2:${NC} Testar conectividade com Fabric Composer"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# shellcheck disable=SC1091
source .env
echo "Testando conexão com: ${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}"
HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" "${FABRIC_COMPOSER_PROTOCOL}://${FABRIC_COMPOSER_IP}/" 2>/dev/null)

if [ "$HTTP_CODE" == "200" ] || [ "$HTTP_CODE" == "401" ] || [ "$HTTP_CODE" == "302" ]; then
    echo "✅ Fabric Composer acessível (HTTP $HTTP_CODE)"
else
    echo "⚠️  HTTP Code: $HTTP_CODE (pode ser esperado se houver redirect ou autenticação)"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}PASSO 3:${NC} Validar configuração (DRY-RUN)"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "Executando dry-run para validar parâmetros..."
echo ""
echo -e "${YELLOW}Comando:${NC}"
echo "./scripts/hybrid/create-aruba-vrf.sh \\"
echo "  --env-file .env \\"
echo "  --name EXEMPLO-VRF \\"
echo "  --fabric default \\"
echo "  --rd 65000:999 \\"
echo "  --rt-import \"65000:999\" \\"
echo "  --rt-export \"65000:999\" \\"
echo "  --af ipv4 \\"
echo "  --description \"VRF de Exemplo\" \\"
echo "  --dry-run"
echo ""

read -p "Executar dry-run agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    ./scripts/hybrid/create-aruba-vrf.sh \
      --env-file .env \
      --name EXEMPLO-VRF \
      --fabric default \
      --rd 65000:999 \
      --rt-import "65000:999" \
      --rt-export "65000:999" \
      --af ipv4 \
      --description "VRF de Exemplo" \
      --dry-run
else
    echo "Dry-run pulado."
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}PASSO 4:${NC} Criar VRF (REAL)"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠️  ATENÇÃO:${NC} O próximo passo irá criar uma VRF REAL no Fabric Composer!"
echo ""
echo -e "${YELLOW}Comando:${NC}"
echo "./scripts/hybrid/create-aruba-vrf.sh \\"
echo "  --env-file .env \\"
echo "  --name EXEMPLO-VRF \\"
echo "  --fabric default \\"
echo "  --rd 65000:999 \\"
echo "  --rt-import \"65000:999\" \\"
echo "  --rt-export \"65000:999\" \\"
echo "  --af ipv4 \\"
echo "  --description \"VRF de Exemplo\""
echo ""

read -p "Criar VRF agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    ./scripts/hybrid/create-aruba-vrf.sh \
      --env-file .env \
      --name EXEMPLO-VRF \
      --fabric default \
      --rd 65000:999 \
      --rt-import "65000:999" \
      --rt-export "65000:999" \
      --af ipv4 \
      --description "VRF de Exemplo"
else
    echo "Criação de VRF cancelada."
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}WORKFLOW CONCLUÍDO${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "📚 Documentação adicional:"
echo "   - QUICKSTART_VRF_AFC.md     (guia rápido)"
echo "   - VRF_UPDATE_SUMMARY.md     (resumo de alterações)"
echo "   - docs/CREATE_ARUBA_VRF.md  (documentação completa)"
echo ""

echo "🔗 Acesso ao Fabric Composer:"
echo "   URL: https://${FABRIC_COMPOSER_IP}"
echo "   Usuário: ${FABRIC_COMPOSER_USERNAME}"
echo ""
