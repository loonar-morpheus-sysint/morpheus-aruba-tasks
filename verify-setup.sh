#!/bin/bash
# verify-setup.sh
# Script para verificar se toda a configuração de testes está correta

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

# 2. Verificar arquivos de teste
echo -n "2. Arquivos de teste: "
TEST_FILES=$(find tests -name "*.bats" 2>/dev/null | wc -l)
if [[ "${TEST_FILES}" -gt 0 ]]; then
    echo -e "${GREEN}✓${NC} (${TEST_FILES} arquivos)"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 3. Verificar test_helper
echo -n "3. Test helper: "
if [[ -f "tests/test_helper.bash" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 4. Verificar run-tests.sh
echo -n "4. Script run-tests.sh: "
if [[ -x "run-tests.sh" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 5. Verificar pre-commit config
echo -n "5. Pre-commit config: "
if grep -q "bats-tests" .pre-commit-config.yaml 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 6. Verificar GitHub Actions
echo -n "6. GitHub Actions workflow: "
if grep -q "bats" .github/workflows/validation.yml 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# 7. Verificar pre-commit instalado
echo -n "7. Pre-commit instalado: "
if command -v pre-commit &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠${NC} (opcional)"
fi

# 8. Contar testes
echo ""
echo -e "${BLUE}Resumo dos testes:${NC}"
for file in tests/test_*.bats; do
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

if ./run-tests.sh > /tmp/bats-output.txt 2>&1; then
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
echo "  1. Execute: ./run-tests.sh"
echo "  2. Corrija scripts para passar nos testes"
echo "  3. Commit com: git commit (pre-commit validará)"
echo ""
echo "Documentação:"
echo "  - TESTING.md       : Guia completo"
echo "  - tests/README.md  : Documentação BATS"
echo "  - QUICK_COMMANDS.md: Comandos úteis"
echo ""
