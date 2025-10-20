#!/bin/bash
################################################################################
# Script: migrate-simple.sh
# Description: Simple migration script to reorganize project structure
################################################################################

set -e

REPO_ROOT="/workspaces/morpheus-aruba-tasks"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           MIGRAÇÃO COMPLETA - ESTRUTURA DO PROJETO             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Etapa 1: Criar estrutura de diretórios
echo "ETAPA 1/5: Criando estrutura de diretórios..."
mkdir -p "${REPO_ROOT}/lib"
mkdir -p "${REPO_ROOT}/scripts/aruba/auth"
mkdir -p "${REPO_ROOT}/scripts/aruba/vrf"
mkdir -p "${REPO_ROOT}/scripts/aruba/backup"
mkdir -p "${REPO_ROOT}/scripts/aruba/cli"
mkdir -p "${REPO_ROOT}/scripts/hybrid"
mkdir -p "${REPO_ROOT}/scripts/utilities"
mkdir -p "${REPO_ROOT}/examples"
echo "✓ Estrutura criada"

# Etapa 2: Mover commons.sh de core/ para lib/
echo ""
echo "ETAPA 2/5: Movendo commons.sh..."
if [ -f "${REPO_ROOT}/core/commons.sh" ]; then
    cp "${REPO_ROOT}/core/commons.sh" "${REPO_ROOT}/lib/commons.sh"
    echo "✓ commons.sh copiado para lib/"
else
    echo "⚠ core/commons.sh não encontrado"
fi

# Etapa 3: Mover scripts para nova estrutura
echo ""
echo "ETAPA 3/5: Movendo scripts VRF e relacionados..."

# Scripts VRF Aruba
[ -f "${REPO_ROOT}/create-vrf.sh" ] && mv "${REPO_ROOT}/create-vrf.sh" "${REPO_ROOT}/scripts/aruba/vrf/" && echo "✓ create-vrf.sh movido"
[ -f "${REPO_ROOT}/delete-vrf.sh" ] && mv "${REPO_ROOT}/delete-vrf.sh" "${REPO_ROOT}/scripts/aruba/vrf/" && echo "✓ delete-vrf.sh movido"

# Scripts de autenticação
[ -f "${REPO_ROOT}/aruba-auth.sh" ] && mv "${REPO_ROOT}/aruba-auth.sh" "${REPO_ROOT}/scripts/aruba/auth/" && echo "✓ aruba-auth.sh movido"

# Scripts CLI
[ -f "${REPO_ROOT}/install-aruba-cli.sh" ] && mv "${REPO_ROOT}/install-aruba-cli.sh" "${REPO_ROOT}/scripts/aruba/cli/" && echo "✓ install-aruba-cli.sh movido"

# Scripts híbridos
[ -f "${REPO_ROOT}/create-aruba-vrf.sh" ] && mv "${REPO_ROOT}/create-aruba-vrf.sh" "${REPO_ROOT}/scripts/hybrid/" && echo "✓ create-aruba-vrf.sh movido"
[ -f "${REPO_ROOT}/create-vrf-hybrid.sh" ] && mv "${REPO_ROOT}/create-vrf-hybrid.sh" "${REPO_ROOT}/scripts/hybrid/" && echo "✓ create-vrf-hybrid.sh movido"

# Exemplos
[ -f "${REPO_ROOT}/example-create-vrf.sh" ] && mv "${REPO_ROOT}/example-create-vrf.sh" "${REPO_ROOT}/examples/" && echo "✓ example-create-vrf.sh movido"
[ -f "${REPO_ROOT}/example-vrf-workflow.sh" ] && mv "${REPO_ROOT}/example-vrf-workflow.sh" "${REPO_ROOT}/examples/" && echo "✓ example-vrf-workflow.sh movido"

# Etapa 4: Atualizar referências ao commons.sh nos scripts movidos
echo ""
echo "ETAPA 4/5: Atualizando referências ao commons.sh..."

# Scripts em scripts/aruba/* (3 níveis)
find "${REPO_ROOT}/scripts/aruba" -name "*.sh" -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        sed -i 's|source.*commons\.sh.*|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../lib" \&\& pwd)/commons.sh"|g' "$file"
        echo "  ✓ Atualizado: $(basename "$file")"
    fi
done

# Scripts em scripts/hybrid (2 níveis)
find "${REPO_ROOT}/scripts/hybrid" -name "*.sh" -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        sed -i 's|source.*commons\.sh.*|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" \&\& pwd)/commons.sh"|g' "$file"
        echo "  ✓ Atualizado: $(basename "$file")"
    fi
done

# Scripts em scripts/utilities (2 níveis)
find "${REPO_ROOT}/scripts/utilities" -name "*.sh" -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        sed -i 's|source.*commons\.sh.*|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" \&\& pwd)/commons.sh"|g' "$file"
        echo "  ✓ Atualizado: $(basename "$file")"
    fi
done

# Exemplos (1 nível)
find "${REPO_ROOT}/examples" -name "*.sh" -type f 2>/dev/null | while read -r file; do
    if [ -f "$file" ]; then
        sed -i 's|source.*commons\.sh.*|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" \&\& pwd)/commons.sh"|g' "$file"
        echo "  ✓ Atualizado: $(basename "$file")"
    fi
done

# Etapa 5: Atualizar documentação
echo ""
echo "ETAPA 5/5: Atualizando documentação..."

find "${REPO_ROOT}" -name "*.md" ! -path "*/.git/*" -type f | while read -r file; do
    # Atualizar referências core/commons -> lib/commons
    sed -i 's|core/commons|lib/commons|g' "$file"

    # Atualizar referências a scripts movidos
    sed -i 's|`create-vrf\.sh`|`scripts/aruba/vrf/create-vrf.sh`|g' "$file"
    sed -i 's|`aruba-auth\.sh`|`scripts/aruba/auth/aruba-auth.sh`|g' "$file"
    sed -i 's|`install-aruba-cli\.sh`|`scripts/aruba/cli/install-aruba-cli.sh`|g' "$file"
    sed -i 's|`create-aruba-vrf\.sh`|`scripts/hybrid/create-aruba-vrf.sh`|g' "$file"
    sed -i 's|`create-vrf-hybrid\.sh`|`scripts/hybrid/create-vrf-hybrid.sh`|g' "$file"

    echo "  ✓ Atualizado: $(basename "$file")"
done

# Criar READMEs
cat > "${REPO_ROOT}/scripts/README.md" << 'EOF'
# Scripts Directory

Organized scripts for Aruba and Morpheus automation.

## Structure

- **aruba/** - Aruba-specific scripts
  - **auth/** - Authentication and connection
  - **vrf/** - VRF management
  - **cli/** - CLI installation and management

- **hybrid/** - Hybrid scripts (Aruba + Morpheus integration)
- **utilities/** - General utility scripts

## Usage

All scripts use the central library: `../lib/commons.sh`
EOF

cat > "${REPO_ROOT}/examples/README.md" << 'EOF'
# Examples Directory

Practical examples demonstrating script usage.

## Available Examples

- **example-create-vrf.sh** - Example of VRF creation
- **example-vrf-workflow.sh** - Complete VRF workflow example

## Running Examples

```bash
cd examples
./example-create-vrf.sh
```

All examples use the central library: `../lib/commons.sh`
EOF

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                MIGRAÇÃO CONCLUÍDA COM SUCESSO!                 ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Resumo:"
echo "  ✓ commons.sh: core/ → lib/"
echo "  ✓ Scripts VRF: → scripts/aruba/vrf/"
echo "  ✓ Scripts Auth: → scripts/aruba/auth/"
echo "  ✓ Scripts CLI: → scripts/aruba/cli/"
echo "  ✓ Scripts Híbridos: → scripts/hybrid/"
echo "  ✓ Exemplos: → examples/"
echo "  ✓ Referências atualizadas"
echo ""
echo "Próximos passos:"
echo "  1. Verificar estrutura: tree -L 3 scripts/ examples/ lib/"
echo "  2. Testar um script: bash scripts/aruba/vrf/create-vrf.sh --help"
echo "  3. Executar testes: ./tests/run-tests.sh"
echo ""
