#!/bin/bash
# run-tests.sh
# Script para executar todos os testes BATS do projeto

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧪 Executando Testes BATS${NC}"
echo "=================================="

# Verifica se BATS está instalado
if ! command -v bats &> /dev/null; then
    echo -e "${RED}❌ BATS não está instalado!${NC}"
    echo ""
    echo "Para instalar no Ubuntu/Debian:"
    echo "  sudo apt-get update && sudo apt-get install -y bats"
    echo ""
    echo "Para instalar no macOS:"
    echo "  brew install bats-core"
    exit 1
fi

# Diretório de testes
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/tests" && pwd)"

if [[ ! -d "${TEST_DIR}" ]]; then
    echo -e "${RED}❌ Diretório de testes não encontrado: ${TEST_DIR}${NC}"
    exit 1
fi

# Executa os testes
echo ""
echo -e "${YELLOW}📁 Diretório de testes: ${TEST_DIR}${NC}"
echo ""

# Se um arquivo específico foi passado como argumento
if [[ $# -gt 0 ]]; then
    echo -e "${YELLOW}🎯 Executando teste específico: $1${NC}"
    bats "${TEST_DIR}/$1"
    exit_code=$?
else
    echo -e "${YELLOW}🎯 Executando todos os testes...${NC}"
    bats "${TEST_DIR}"/*.bats
    exit_code=$?
fi

# Resultado
if [[ ${exit_code} -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Alguns testes falharam!${NC}"
    exit 1
fi
