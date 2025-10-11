#!/bin/bash
# Script executado após criação do container

set -e

echo "🔧 Configurando ambiente de desenvolvimento..."

# Instala hooks do pre-commit
if [ -f .pre-commit-config.yaml ]; then
    echo "📋 Instalando hooks do pre-commit..."
    pre-commit install
    pre-commit install --hook-type commit-msg
    echo "✅ Hooks instalados com sucesso!"
else
    echo "⚠️  Arquivo .pre-commit-config.yaml não encontrado"
fi

# Verifica instalação do GitHub CLI
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI instalado"
    gh --version
else
    echo "⚠️  GitHub CLI não encontrado"
fi

# Verifica shellcheck
if command -v shellcheck &> /dev/null; then
    echo "✅ shellcheck instalado"
    shellcheck --version
else
    echo "❌ shellcheck não encontrado"
fi

# Verifica markdownlint
if command -v markdownlint &> /dev/null; then
    echo "✅ markdownlint instalado"
    markdownlint --version
else
    echo "❌ markdownlint não encontrado"
fi

# Verifica pre-commit
if command -v pre-commit &> /dev/null; then
    echo "✅ pre-commit instalado"
    pre-commit --version
else
    echo "❌ pre-commit não encontrado"
fi

echo "🎉 Configuração concluída!"
