#!/bin/bash
################################################################################
# Script: move-test-scripts.sh
# Description: Moves manual test scripts to tests/manual/ directory
################################################################################

set -e

REPO_ROOT="/workspaces/morpheus-aruba-tasks"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         MOVENDO SCRIPTS DE TESTE PARA tests/manual/           ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Criar diretório para testes manuais
echo "Criando diretório tests/manual/..."
mkdir -p "${REPO_ROOT}/tests/manual"
echo "✓ Diretório criado"

echo ""
echo "Movendo scripts de teste..."

# Mover arquivos de teste
TEST_FILES=(
    "test-vrf-creation.sh"
    "test-hybrid-afc.sh"
    "test-hybrid-aoscx.sh"
    "test-script.sh"
)

for file in "${TEST_FILES[@]}"; do
    if [ -f "${REPO_ROOT}/${file}" ]; then
        echo "  Movendo: ${file} → tests/manual/"
        mv "${REPO_ROOT}/${file}" "${REPO_ROOT}/tests/manual/"

        # Atualizar referência ao commons.sh
        sed -i 's|source "$(cd "$(dirname "${BASH_SOURCE\[0\]}")/../lib" \&\& pwd)/commons.sh"|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" \&\& pwd)/commons.sh"|g' "${REPO_ROOT}/tests/manual/${file}"
        echo "    ✓ Referências ao commons.sh atualizadas"
    else
        echo "  ⚠ Não encontrado: ${file}"
    fi
done

# Criar README para testes manuais
echo ""
echo "Criando README para tests/manual/..."

cat > "${REPO_ROOT}/tests/manual/README.md" << 'MANUAL_README'
# Manual Tests Directory

Scripts for manual integration testing and validation.

## Available Test Scripts

- **test-vrf-creation.sh** - Test VRF creation with Fabric Composer
- **test-hybrid-afc.sh** - Test Hybrid VRF creation (Fabric Composer mode)
- **test-hybrid-aoscx.sh** - Test Hybrid VRF creation (AOS-CX mode)
- **test-script.sh** - Simple Hello World test script

## Usage

These scripts are meant for manual testing and validation during development.

```bash
cd tests/manual
./test-vrf-creation.sh
./test-hybrid-afc.sh
./test-hybrid-aoscx.sh
```

## Automated Tests

For automated unit/integration tests, see the `.bats` files in the parent `tests/` directory:

```bash
cd tests
./run-tests.sh
```

All manual test scripts use the central library: `../../lib/commons.sh`
MANUAL_README

echo "✓ README criado"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    MIGRAÇÃO CONCLUÍDA!                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Nova estrutura:"
echo "  tests/"
echo "  ├── manual/              # Testes manuais"
echo "  │   ├── test-vrf-creation.sh"
echo "  │   ├── test-hybrid-afc.sh"
echo "  │   ├── test-hybrid-aoscx.sh"
echo "  │   └── test-script.sh"
echo "  ├── *.bats              # Testes automatizados BATS"
echo "  └── run-tests.sh        # Executor de testes"
echo ""
