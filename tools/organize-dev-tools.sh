#!/bin/bash
################################################################################
# Script: organize-dev-tools.sh
# Description: Organizes development utility scripts into tools/ directory
################################################################################

set -e

REPO_ROOT="/workspaces/morpheus-aruba-tasks"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       ORGANIZANDO SCRIPTS DE DESENVOLVIMENTO EM tools/         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Scripts de desenvolvimento/utilidades para mover
DEV_TOOLS=(
    "copilot-sync-devcontainer.sh"
    "generate-copilot-instructions.sh"
    "update-devcontainer-sync.sh"
    "watch-agents.sh"
    "move-test-scripts.sh"
)

echo "Movendo scripts de desenvolvimento para tools/..."
echo ""

for file in "${DEV_TOOLS[@]}"; do
    if [ -f "${REPO_ROOT}/${file}" ]; then
        echo "  Movendo: ${file} → tools/"
        mv "${REPO_ROOT}/${file}" "${REPO_ROOT}/tools/"

        # Atualizar referências ao commons.sh se existirem
        if grep -q "source.*commons\.sh" "${REPO_ROOT}/tools/${file}" 2>/dev/null; then
            sed -i 's|source.*commons\.sh.*|source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../lib" \&\& pwd)/commons.sh"|g' "${REPO_ROOT}/tools/${file}"
            echo "    ✓ Referências ao commons.sh atualizadas"
        fi
    else
        echo "  ⚠ Não encontrado: ${file}"
    fi
done

# Criar README para tools/
echo ""
echo "Criando README para tools/..."

cat > "${REPO_ROOT}/tools/README.md" << 'TOOLS_README'
# Development Tools Directory

Utility scripts for project development, maintenance, and automation.

## Migration Tools

- **migrate-bash-layout.sh** - Migrates project structure to standardized layout
- **migrate-simple.sh** - Simplified migration script

## Documentation Tools

- **generate-copilot-instructions.sh** - Generates Copilot instructions from AGENTS.md
- **watch-agents.sh** - Monitors AGENTS.md changes and regenerates instructions

## DevContainer Tools

- **copilot-sync-devcontainer.sh** - Syncs devcontainer.json with documentation
- **update-devcontainer-sync.sh** - Guides user to sync devcontainer files

## Test Utilities

- **move-test-scripts.sh** - Organizes manual test scripts

## Usage

These scripts are for project maintenance and should be run from the repository root:

```bash
# Generate Copilot instructions
./tools/generate-copilot-instructions.sh

# Watch for AGENTS.md changes
./tools/watch-agents.sh

# Sync devcontainer documentation
./tools/copilot-sync-devcontainer.sh
```

## Note

These tools use the central library when applicable: `../lib/commons.sh`
TOOLS_README

echo "✓ README criado"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ORGANIZAÇÃO CONCLUÍDA!                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Estrutura tools/:"
ls -1 "${REPO_ROOT}/tools/"
echo ""
echo "Arquivos restantes na raiz:"
ls -1 "${REPO_ROOT}/"*.sh 2>/dev/null || echo "  (nenhum arquivo .sh na raiz)"
echo ""
