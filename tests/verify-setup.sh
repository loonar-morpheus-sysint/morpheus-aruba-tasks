#!/bin/bash
################################################################################
# Script: verify-setup.sh
# Description: Verifica se a configuração de testes está correta
################################################################################
#
# DESCRIÇÃO DETALHADA:
#   Valida toda a infraestrutura de testes BATS do projeto,
#   incluindo instalação, configuração e execução.
#
# USO:
#   ./tests/verify-setup.sh
#
################################################################################

set -e

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Verificação de Configuração BATS     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Define PROJECT_ROOT relativo a este script
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 1. Verificar BATS
echo -n "1. BATS instalado: "
if command -v bats &> /dev/null; then
    VERSION=$(bats --version | awk '{print $2}')
    echo -e "${GREEN}✓${NC} (v${VERSION})"
else
    echo -e "${RED}✗${NC}"
    echo "   Instale com: sudo apt-get install -y bats"
    exit 1
fi

# 2. Verificar diretório de testes
echo -n "2. Diretório tests/: "
if [[ -d "${PROJECT_ROOT}/tests" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 3. Verificar test_helper.bash
echo -n "3. test_helper.bash: "
if [[ -f "${PROJECT_ROOT}/tests/test_helper.bash" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 4. Verificar arquivos de teste
echo -n "4. Arquivos .bats: "
BATS_COUNT=$(find "${PROJECT_ROOT}/tests" -name "*.bats" -type f | wc -l)
if [[ ${BATS_COUNT} -gt 0 ]]; then
    echo -e "${GREEN}✓${NC} (${BATS_COUNT} arquivos)"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 5. Verificar script run-tests.sh
echo -n "5. run-tests.sh: "
if [[ -f "${PROJECT_ROOT}/tests/run-tests.sh" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
fi

# 6. Verificar pre-commit
echo -n "6. Pre-commit instalado: "
if command -v pre-commit &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} (opcional)"
fi

# 7. Verificar hooks Git
echo -n "7. Git hooks instalados: "
if [[ -f "${PROJECT_ROOT}/.git/hooks/pre-commit" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} (opcional)"
fi

# 8. Contar testes
echo ""
echo -e "${BLUE}Resumo dos testes:${NC}"
for file in "${PROJECT_ROOT}"/tests/test_*.bats; do
    if [[ -f "${file}" ]]; then
        COUNT=$(grep -c "@test" "${file}")
        FILENAME=$(basename "${file}")
        echo "  - ${FILENAME}: ${COUNT} testes"
    fi
done

# 9. Executar testes
echo ""
echo -e "${BLUE}Executando testes...${NC}"
echo ""

if "${PROJECT_ROOT}/tests/run-tests.sh" > /tmp/bats-output.txt 2>&1; then
    echo -e "${GREEN}✓ Todos os testes passaram!${NC}"
    tail -n 3 /tmp/bats-output.txt
else
    echo -e "${YELLOW}⚠ Alguns testes falharam (esperado)${NC}"
    tail -n 3 /tmp/bats-output.txt
fi

# 10. Resultado final
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Status: ${GREEN}CONFIGURAÇÃO COMPLETA${BLUE}      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Execute: ./tests/run-tests.sh"
echo "  2. Corrija scripts para passar nos testes"
echo "  3. Commit com: git commit (pre-commit validará)"
echo ""
echo "Documentação:"
echo "  - TESTING.md       : Guia completo"
echo "  - tests/README.md  : Documentação BATS"
echo "  - QUICK_COMMANDS.md: Comandos úteis"
echo ""
