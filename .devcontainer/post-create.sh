#!/bin/bash
# Script executado após criação do container

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Configurando ambiente de desenvolvimento Morpheus Aruba Tasks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Função para verificar e exibir versão de ferramenta
check_tool() {
  local tool_name="$1"
  local tool_cmd="$2"
  local version_flag="${3:---version}"
  
  if command -v "${tool_cmd}" &> /dev/null; then
    local version
    version=$("${tool_cmd}" "${version_flag}" 2>&1 | head -n 1) || true
    echo "✅ ${tool_name}: ${version}"
    return 0
  else
    echo "❌ ${tool_name} não encontrado"
    return 1
  fi
}

echo ""
echo "📦 Verificando ferramentas instaladas..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Core Tools
echo ""
echo "🔨 Ferramentas Core:"
check_tool "Git" "git" "--version"
check_tool "GitHub CLI" "gh" "--version"
check_tool "Curl" "curl" "--version"
check_tool "jq" "jq" "--version"

# Python Ecosystem
echo ""
echo "🐍 Ecossistema Python:"
check_tool "Python" "python3" "--version"
check_tool "pip" "pip3" "--version"
check_tool "pylint" "pylint" "--version"
check_tool "flake8" "flake8" "--version"
check_tool "black" "black" "--version"
check_tool "mypy" "mypy" "--version"
check_tool "bandit" "bandit" "--version"
check_tool "pytest" "pytest" "--version"

# Node.js Ecosystem
echo ""
echo "📦 Ecossistema Node.js:"
check_tool "Node.js" "node" "--version"
check_tool "npm" "npm" "--version"
check_tool "markdownlint" "markdownlint" "--version"
check_tool "prettier" "prettier" "--version"
check_tool "typescript" "tsc" "--version"

# Bash Development
echo ""
echo "🐚 Ferramentas Bash:"
check_tool "shellcheck" "shellcheck" "--version"
check_tool "shfmt" "shfmt" "--version"
check_tool "yamllint" "yamllint" "--version"
check_tool "bash-language-server" "bash-language-server" "--version"

# Security & Quality
echo ""
echo "🔒 Ferramentas de Segurança e Qualidade:"
check_tool "pre-commit" "pre-commit" "--version"
check_tool "detect-secrets" "detect-secrets" "--version"
check_tool "ansible-lint" "ansible-lint" "--version"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Configurando hooks e ferramentas..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Instala hooks do pre-commit
if [[ -f .pre-commit-config.yaml ]]; then
  echo "📋 Instalando hooks do pre-commit..."
  if pre-commit install; then
    echo "✅ Pre-commit hooks instalados"
  else
    echo "⚠️  Falha ao instalar pre-commit hooks"
  fi
  
  if pre-commit install --hook-type commit-msg; then
    echo "✅ Commit-msg hooks instalados"
  else
    echo "⚠️  Falha ao instalar commit-msg hooks"
  fi
else
  echo "⚠️  Arquivo .pre-commit-config.yaml não encontrado"
fi

# Configura permissões de execução para scripts
echo ""
echo "🔑 Configurando permissões de execução..."
if [[ -d "/workspaces/morpheus-aruba-tasks" ]]; then
  chmod +x /workspaces/morpheus-aruba-tasks/*.sh 2>/dev/null || true
  echo "✅ Permissões configuradas para scripts .sh"
fi

# Cria diretórios úteis se não existirem
echo ""
echo "📁 Criando estrutura de diretórios..."
mkdir -p logs backups tmp configs
echo "✅ Diretórios criados: logs/ backups/ tmp/ configs/"

# Informações do ambiente
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ℹ️  Informações do Ambiente"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
os_info=$(lsb_release -d 2>/dev/null | cut -f2-) || os_info="Unknown"
current_user=$(whoami 2>/dev/null) || current_user="Unknown"
echo "Sistema Operacional: ${os_info}"
echo "Shell: ${SHELL}"
echo "Usuário: ${current_user}"
echo "Workspace: ${PWD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "🎉 Configuração concluída com sucesso!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Dicas:"
echo "  • Execute 'shellcheck script.sh' para validar scripts"
echo "  • Execute 'markdownlint *.md' para validar documentação"
echo "  • Execute 'pre-commit run --all-files' para validar tudo"
echo "  • Use 'gh' para interagir com GitHub"
echo ""
echo "🚀 Pronto para começar o desenvolvimento!"
echo ""
