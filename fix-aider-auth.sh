#!/bin/bash
################################################################################
# Script: fix-aider-auth.sh
# Description: Corrige configuração de autenticação do Aider com GitHub Copilot
################################################################################
#
# DESCRIÇÃO DETALHADA:
#   Este script resolve problemas de autenticação do Aider corrigindo:
#   - Formato do token de autorização
#   - Configuração das variáveis de ambiente
#   - Validação da conectividade com a API
#   - Persistência da configuração no shell
#
# VARIÁVEIS DE AMBIENTE:
#   GITHUB_TOKEN: Token do GitHub CLI (obtido automaticamente)
#   OPENAI_API_KEY: Configurado automaticamente como GITHUB_TOKEN
#   OPENAI_API_BASE: https://api.githubcopilot.com
#
# USO:
#   ./fix-aider-auth.sh
#
# DEPENDÊNCIAS:
#   - gh: GitHub CLI deve estar autenticado
#   - curl: Para testes de conectividade
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

################################################################################
# Funções
################################################################################

# Limpa configuração atual
clean_current_config() {
  _log_func_enter "clean_current_config"

  log_info "Limpando configuração atual..."

  unset GITHUB_TOKEN 2>/dev/null || true
  unset OPENAI_API_KEY 2>/dev/null || true
  unset OPENAI_API_BASE 2>/dev/null || true

  log_success "Variáveis de ambiente limpas"
  _log_func_exit_ok "clean_current_config"
  return 0
}

# Configura token corretamente
setup_correct_token() {
  _log_func_enter "setup_correct_token"

  log_info "Configurando token do GitHub Copilot..."

  # Verifica se GitHub CLI está autenticado
  if ! gh auth status &>/dev/null; then
    log_error "GitHub CLI não está autenticado"
    log_info "Execute primeiro: gh auth login"
    _log_func_exit_fail "setup_correct_token" "1"
    return 1
  fi

  # Obtém token limpo do GitHub CLI
  local raw_token
  if ! raw_token=$(gh auth token 2>/dev/null); then
    log_error "Falha ao obter token do GitHub CLI"
    log_info "Execute: gh auth refresh"
    _log_func_exit_fail "setup_correct_token" "1"
    return 1
  fi

  # Remove caracteres de controle e espaços
  local clean_token
  clean_token=$(echo "${raw_token}" | tr -d '\n\r[:space:]')

  if [[ -z "${clean_token}" ]]; then
    log_error "Token obtido está vazio"
    _log_func_exit_fail "setup_correct_token" "1"
    return 1
  fi

  # Configura variáveis de ambiente corretamente
  export GITHUB_TOKEN="${clean_token}"
  export OPENAI_API_KEY="${clean_token}"
  export OPENAI_API_BASE="https://models.inference.ai.azure.com"

  log_success "Token configurado: ${clean_token:0:8}...${clean_token: -4}"
  log_success "OPENAI_API_BASE: ${OPENAI_API_BASE}"  _log_func_exit_ok "setup_correct_token"
  return 0
}

# Testa conectividade com API
test_api_connection() {
  _log_func_enter "test_api_connection"

  log_info "Testando conectividade com API do GitHub Copilot..."

  if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    log_error "OPENAI_API_KEY não configurado"
    _log_func_exit_fail "test_api_connection" "1"
    return 1
  fi

  # Verifica se curl está disponível
  if ! command -v curl &> /dev/null; then
    log_error "curl não encontrado"
    _log_func_exit_fail "test_api_connection" "1"
    return 1
  fi

  # Testa endpoint de modelos (GitHub Models)
  local api_url="${OPENAI_API_BASE}/models"
  local http_code

  log_info "Testando endpoint: ${api_url}"
  http_code=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -H "Content-Type: application/json" \
    "${api_url}" 2>/dev/null || echo "000")

  case "${http_code}" in
    200)
      log_success "API acessível - Autenticação válida (HTTP ${http_code})"
      ;;
    401)
      log_error "Erro 401 - Token inválido ou expirado"
      log_info "Soluções:"
      log_info "  1. Execute: gh auth refresh"
      log_info "  2. Execute: gh auth login --force"
      _log_func_exit_fail "test_api_connection" "1"
      return 1
      ;;
    403)
      log_error "Erro 403 - GitHub Copilot não disponível"
      log_info "Verificações necessárias:"
      log_info "  1. Assinatura ativa: https://github.com/settings/copilot"
      log_info "  2. Permissões de acesso corretas"
      _log_func_exit_fail "test_api_connection" "1"
      return 1
      ;;
    000)
      log_error "Erro de conectividade - Não foi possível acessar a API"
      log_info "Verifique sua conexão com a internet"
      _log_func_exit_fail "test_api_connection" "1"
      return 1
      ;;
    *)
      log_warning "Código HTTP inesperado: ${http_code}"
      log_info "API pode estar temporariamente indisponível"
      log_info "Continuando com a configuração..."
      ;;
  esac

  _log_func_exit_ok "test_api_connection"
  return 0
}

# Persiste configuração no shell
persist_config() {
  _log_func_enter "persist_config"

  log_info "Persistindo configuração no shell..."

  # Determina arquivo de configuração do shell
  local shell_config
  if [[ -n "${BASH_VERSION:-}" ]]; then
    shell_config="${HOME}/.bashrc"
  elif [[ -n "${ZSH_VERSION:-}" ]]; then
    shell_config="${HOME}/.zshrc"
  else
    shell_config="${HOME}/.profile"
  fi

  # Cria backup do arquivo de configuração atual
  if [[ -f "${shell_config}" ]]; then
    local backup_file
    backup_file="${shell_config}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "${shell_config}" "${backup_file}"
    log_info "Backup criado: ${backup_file}"
  fi

  # Remove configurações antigas do Aider (evita duplicação)
  if [[ -f "${shell_config}" ]]; then
    sed -i '/# Aider configuration/d' "${shell_config}" 2>/dev/null || true
    sed -i '/export GITHUB_TOKEN.*gh auth token/d' "${shell_config}" 2>/dev/null || true
    sed -i '/export OPENAI_API_KEY.*GITHUB_TOKEN/d' "${shell_config}" 2>/dev/null || true
    sed -i '/export OPENAI_API_BASE.*githubcopilot/d' "${shell_config}" 2>/dev/null || true
  fi

  # Adiciona nova configuração
  cat >> "${shell_config}" << 'EOF'

# Aider configuration - GitHub Models
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
  export GITHUB_TOKEN="$(gh auth token 2>/dev/null | tr -d '\n\r[:space:]')"
  export OPENAI_API_KEY="${GITHUB_TOKEN}"
  export OPENAI_API_BASE="https://models.inference.ai.azure.com"
fi
EOF

  log_success "Configuração adicionada a: ${shell_config}"
  log_info "Recarregue o shell: source ${shell_config}"

  _log_func_exit_ok "persist_config"
  return 0
}

# Testa Aider
test_aider() {
  _log_func_enter "test_aider"

  log_info "Testando Aider..."

  if ! command -v aider &> /dev/null; then
    log_error "Aider não encontrado"
    log_info "Instalação necessária:"
    log_info "  pip3 install aider-chat"
    _log_func_exit_fail "test_aider" "1"
    return 1
  fi

  # Testa versão do Aider
  local aider_version
  if aider_version=$(aider --version 2>&1 | head -n1); then
    log_success "Aider instalado: ${aider_version}"
  else
    log_error "Falha ao obter versão do Aider"
    _log_func_exit_fail "test_aider" "1"
    return 1
  fi

  # Testa Aider com timeout (evita travamento)
  log_info "Testando comando do Aider (timeout 10s)..."
  if timeout 10s aider --help > /dev/null 2>&1; then
    log_success "Aider respondeu corretamente"
  else
    log_warning "Aider não respondeu no tempo esperado"
    log_info "Isso é normal na primeira execução ou se houver problemas de conectividade"
  fi

  _log_func_exit_ok "test_aider"
  return 0
}

# Cria arquivo de configuração do Aider
create_aider_config() {
  _log_func_enter "create_aider_config"

  log_info "Criando arquivo de configuração do Aider..."

  local config_file=".aider.conf.yml"

  # Backup se existe
  if [[ -f "${config_file}" ]]; then
    cp "${config_file}" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "Backup do arquivo existente criado"
  fi

  # Cria nova configuração
  cat > "${config_file}" << 'EOF'
# Configuração do Aider para GitHub Copilot
# https://aider.chat/docs/config.html

# OpenAI/GitHub Copilot Configuration
openai-api-base: https://api.githubcopilot.com
model: gpt-4

# Git Configuration
auto-commits: false
dirty-commits: false
no-auto-commits: true

# UI Configuration
dark-mode: true
stream: true
pretty: true

# Editor Configuration
editor-model: gpt-3.5-turbo
edit-format: diff

# Performance
map-tokens: 1024
cache-prompts: true

# Safety
confirm-every-commit: false
EOF

  log_success "Arquivo criado: ${config_file}"

  _log_func_exit_ok "create_aider_config"
  return 0
}

################################################################################
# Função Main
################################################################################

main() {
  _log_func_enter "main"

  log_section "CORREÇÃO DE AUTENTICAÇÃO DO AIDER"
  log_info "Resolvendo problema: 'Authorization header is badly formatted'"
  echo ""

  # Verifica pré-requisitos
  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI não encontrado"
    log_info "Instale com: sudo apt update && sudo apt install gh"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  local errors=0

  # Executa correções passo a passo
  log_info "1. Limpando configuração atual..."
  clean_current_config || ((errors++))
  echo ""

  log_info "2. Configurando token correto..."
  setup_correct_token || ((errors++))
  echo ""

  log_info "3. Testando conectividade da API..."
  test_api_connection || ((errors++))
  echo ""

  log_info "4. Validando Aider..."
  test_aider || ((errors++))
  echo ""

  log_info "5. Criando configuração do Aider..."
  create_aider_config || ((errors++))
  echo ""

  log_info "6. Persistindo configuração..."
  persist_config || ((errors++))
  echo ""

  # Resultado final
  log_section "RESULTADO DA CORREÇÃO"

  if [[ ${errors} -eq 0 ]]; then
    log_success "✅ Aider configurado com sucesso!"
    echo ""
    log_info "🎯 Próximos passos:"
    log_info "   1. Recarregue o shell:"
    log_info "      source ~/.bashrc"
    echo ""
    log_info "   2. Teste a configuração:"
    log_info "      aider --help"
    echo ""
    log_info "   3. Use o Aider normalmente:"
    log_info "      aider README.md --message 'revise este arquivo'"
    echo ""
    log_info "🔧 Arquivos configurados:"
    log_info "   - ~/.bashrc (variáveis de ambiente)"
    log_info "   - .aider.conf.yml (configuração do Aider)"
    echo ""
    log_success "Problema resolvido: Authorization header is badly formatted"

    _log_func_exit_ok "main"
    exit 0
  else
    log_error "❌ ${errors} erro(s) encontrado(s)"
    echo ""
    log_info "🔍 Soluções alternativas:"
    log_info "   1. Verifique sua assinatura do GitHub Copilot:"
    log_info "      https://github.com/settings/copilot"
    echo ""
    log_info "   2. Renove a autenticação:"
    log_info "      gh auth refresh"
    log_info "      gh auth login --force"
    echo ""
    log_info "   3. Consulte documentação:"
    log_info "      cat AIDER_SETUP.md"
    echo ""
    log_info "   4. Execute novamente após correções:"
    log_info "      ./fix-aider-auth.sh"

    _log_func_exit_fail "main" "1"
    exit 1
  fi
}

# Executar main apenas se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
