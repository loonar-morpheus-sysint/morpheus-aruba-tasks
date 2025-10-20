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
check_tool "Git" "git" "--version" || true
check_tool "GitHub CLI" "gh" "--version" || true
check_tool "Curl" "curl" "--version" || true
check_tool "jq" "jq" "--version" || true
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

# Instala Aider AI
echo ""
echo "🤖 Instalando Aider AI..."
if pip3 install --user --quiet aider-chat 2>/dev/null; then
  echo "✅ Aider instalado com sucesso"
  # Garante que o diretório de binários do usuário está no PATH
  export PATH="/home/vscode/.local/bin:$PATH"
  echo "export PATH=\"/home/vscode/.local/bin:\$PATH\"" >> /home/vscode/.bashrc
else
  echo "❌ Falha ao instalar Aider"
fi

# Continua verificação de ferramentas Python
check_tool "pylint" "pylint" "--version" || true
check_tool "flake8" "flake8" "--version" || true
check_tool "black" "black" "--version" || true
check_tool "mypy" "mypy" "--version" || true
check_tool "bandit" "bandit" "--version" || true
check_tool "pytest" "pytest" "--version" || true
check_tool "Aider AI" "aider" "--version" || true

# Node.js Ecosystem
echo ""
echo "📦 Ecossistema Node.js:"
check_tool "Node.js" "node" "--version" || true
check_tool "npm" "npm" "--version" || true
check_tool "markdownlint" "markdownlint" "--version" || true
check_tool "prettier" "prettier" "--version" || true
check_tool "typescript" "tsc" "--version" || true

# Bash Development
echo ""
echo "🐚 Ferramentas Bash:"
check_tool "shellcheck" "shellcheck" "--version" || true
check_tool "shfmt" "shfmt" "--version" || true
check_tool "BATS" "bats" "--version" || true
check_tool "yamllint" "yamllint" "--version" || true
check_tool "bash-language-server" "bash-language-server" "--version" || true
check_tool "inotifywait" "inotifywait" "--help" || true

# Security & Quality
echo ""
echo "🔒 Ferramentas de Segurança e Qualidade:"
check_tool "pre-commit" "pre-commit" "--version" || true
check_tool "detect-secrets" "detect-secrets" "--version" || true
check_tool "ansible-lint" "ansible-lint" "--version" || true

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

# Configuração do Git e arquivos de configuração
echo ""
echo "🔧 Configurando Git e arquivos de configuração..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar se .gitconfig foi montado do host
if [[ -f /home/vscode/.gitconfig ]]; then
  echo "✅ .gitconfig montado do host"
  echo "   Nome: $(git config --global user.name 2>/dev/null || echo 'Não configurado')"
  echo "   Email: $(git config --global user.email 2>/dev/null || echo 'Não configurado')"
else
  echo "⚠️  .gitconfig não encontrado, configurando valores padrão..."
  # Configurar Git se não estiver configurado
  if ! git config --global user.name >/dev/null 2>&1; then
    echo "⚙️  Configurando nome do usuário Git..."
    git config --global user.name "DevContainer User"
  fi

  if ! git config --global user.email >/dev/null 2>&1; then
    echo "⚙️  Configurando email do usuário Git..."
    git config --global user.email "user@devcontainer.local"
  fi

  echo "✅ Git configurado:"
  echo "   Nome: $(git config --global user.name)"
  echo "   Email: $(git config --global user.email)"
fi

# Verificar se configuração do GitHub CLI foi montada
if [[ -d /home/vscode/.config/gh ]]; then
  echo "✅ Configuração GitHub CLI montada do host"

  # Verificar autenticação
  if gh auth status &>/dev/null; then
    echo "✅ GitHub CLI autenticado com sucesso"
    gh auth status 2>&1 | head -n 3 | sed 's/^/   /'
  else
    echo "⚠️  GitHub CLI configurado mas não autenticado"
    echo "   💡 Execute: gh auth login"
  fi
else
  echo "⚠️  Configuração GitHub CLI não montada"
  echo "   💡 Para compartilhar autenticação da WSL/host, adicione ao devcontainer.json:"
  echo "   \"mounts\": [\"source=\${localEnv:HOME}/.config/gh,target=/home/vscode/.config/gh,type=bind\"]"
fi

# Verificar chaves SSH
if [[ -d /home/vscode/.ssh ]] && [[ -n "$(ls -A /home/vscode/.ssh 2>/dev/null)" ]]; then
  echo "✅ Chaves SSH montadas do host"
  echo "   Chaves disponíveis:"
  ls -1 /home/vscode/.ssh/*.pub 2>/dev/null | sed 's|/home/vscode/.ssh/||' | sed 's/^/   - /' || echo "   (nenhuma chave pública encontrada)"
else
  echo "⚠️  Chaves SSH não montadas ou diretório vazio"
fi

# Configurações adicionais do Git para o DevContainer
git config --global init.defaultBranch main 2>/dev/null || true
git config --global pull.rebase false 2>/dev/null || true
git config --global core.autocrlf input 2>/dev/null || true
echo "✅ Configurações adicionais do Git aplicadas"
echo "   Branch padrão: $(git config --global init.defaultBranch 2>/dev/null || echo 'main')"

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

# Valida configuração do Aider
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Validando configuração do Aider AI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v aider &> /dev/null; then
  echo "✅ Aider está disponível no PATH"

  # Verifica se o diretório ai-support existe
  if [[ -d "/workspaces/morpheus-aruba-tasks/ai-support" ]]; then
    echo "✅ Diretório ai-support/ encontrado"

    # Verifica scripts
    if [[ -x "/workspaces/morpheus-aruba-tasks/ai-support/scripts/validate-aider.sh" ]]; then
      echo "✅ Scripts de suporte disponíveis"
    fi

    # Verifica config
    if [[ -f "/workspaces/morpheus-aruba-tasks/ai-support/config/.aider.conf.yml" ]]; then
      echo "✅ Arquivo de configuração encontrado"

      # Cria symlink se não existir
      if [[ ! -L "/workspaces/morpheus-aruba-tasks/.aider.conf.yml" ]]; then
        ln -sf /workspaces/morpheus-aruba-tasks/ai-support/config/.aider.conf.yml \
               /workspaces/morpheus-aruba-tasks/.aider.conf.yml
        echo "✅ Symlink de configuração criado"
      fi
    fi

    # Verifica documentação
    if [[ -d "/workspaces/morpheus-aruba-tasks/ai-support/docs" ]]; then
      echo "✅ Documentação disponível em ./ai-support/docs/"
    fi
  else
    echo "⚠️  Diretório ai-support/ não encontrado"
  fi

  # Verifica variáveis de ambiente
  if [[ -n "${OPENAI_API_BASE}" ]]; then
    echo "✅ OPENAI_API_BASE configurado: ${OPENAI_API_BASE}"
  else
    echo "⚠️  OPENAI_API_BASE não configurado"
  fi

  if [[ -n "${OPENAI_API_KEY}" ]]; then
    echo "✅ OPENAI_API_KEY configurado (valor oculto)"
  else
    echo "⚠️  OPENAI_API_KEY não configurado"
    echo "   💡 Defina a variável de ambiente GITHUB_TOKEN para usar o GitHub Copilot"
  fi

  if [[ -n "${AIDER_MODEL}" ]]; then
    echo "✅ Modelo configurado: ${AIDER_MODEL}"
  else
    echo "⚠️  AIDER_MODEL não configurado (usando padrão)"
  fi

  if [[ -n "${AIDER_CONFIG}" ]]; then
    echo "✅ AIDER_CONFIG configurado: ${AIDER_CONFIG}"
  fi
else
  echo "❌ Aider não está disponível"
  echo "   💡 Execute: pip3 install aider-chat"
fi

# Iniciar watcher do AGENTS.md em background
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "👁️  Iniciando AGENTS.md Watcher"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ -f "tools/watch-agents.sh" ]]; then
  # Torna o script executável
  chmod +x tools/watch-agents.sh

  # Inicia em background
  if ./tools/watch-agents.sh --background; then
    echo "✅ AGENTS.md watcher iniciado em background"
    echo "   📝 Mudanças no AGENTS.md serão detectadas automaticamente"
    echo "   📄 Copilot instructions serão regeneradas automaticamente"
    echo "   📊 Para verificar status: ./tools/watch-agents.sh --status"
    echo "   🛑 Para parar: ./tools/watch-agents.sh --stop"
  else
    echo "⚠️  Falha ao iniciar watcher (não crítico)"
  fi
else
  echo "⚠️  Script tools/watch-agents.sh não encontrado"
fi

echo ""
echo "🎉 Configuração concluída com sucesso!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Dicas:"
echo "  • Execute 'shellcheck script.sh' para validar scripts"
echo "  • Execute 'markdownlint *.md' para validar documentação"
echo "  • Execute 'pre-commit run --all-files' para validar tudo"
echo "  • Use 'gh' para interagir com GitHub"
echo "  • Use 'aider' para desenvolvimento assistido por IA com GitHub Copilot"
echo "  • O AGENTS.md está sendo monitorado automaticamente! ✨"
echo ""
echo "🚀 Pronto para começar o desenvolvimento!"
echo ""
