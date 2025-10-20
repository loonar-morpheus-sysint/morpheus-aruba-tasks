#!/bin/bash
################################################################################
# Script: setup-github-token.sh
# Description: Extrai e configura token do GitHub para uso com Aider
################################################################################
#
# DESCRIÇÃO DETALHADA:
#   Este script extrai o token de autenticação do GitHub CLI (gh) e configura
#   a variável de ambiente GITHUB_TOKEN para uso com Aider e outras ferramentas.
#   O token é extraído do comando 'gh auth status --show-token' e exportado
#   para o ambiente atual.
#
# VARIÁVEIS DE AMBIENTE:
#   GITHUB_TOKEN: Token de autenticação do GitHub (configurado pelo script)
#
# USO:
#   source ./setup-github-token.sh
#   # ou
#   ./setup-github-token.sh
#
# EXEMPLOS:
#   source ./setup-github-token.sh && aider
#   ./setup-github-token.sh && echo "Token: $GITHUB_TOKEN"
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

################################################################################
# Funções
################################################################################

# Verifica se GitHub CLI está instalado e autenticado
check_gh_auth() {
  _log_func_enter "check_gh_auth"

  # Verifica se gh está instalado
  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) não está instalado"
    log_info "Para instalar: apt-get install gh"
    _log_func_exit_fail "check_gh_auth" "1"
    return 1
  fi

  log_info "GitHub CLI encontrado: $(gh --version | head -1)"

  # Verifica se está autenticado
  if ! gh auth status &> /dev/null; then
    log_error "GitHub CLI não está autenticado"
    log_info "Execute: gh auth login"
    _log_func_exit_fail "check_gh_auth" "1"
    return 1
  fi

  log_success "GitHub CLI está autenticado"
  _log_func_exit_ok "check_gh_auth"
  return 0
}

# Extrai o token do GitHub CLI
extract_github_token() {
  _log_func_enter "extract_github_token"
  local token_output
  local token

  log_info "Extraindo token do GitHub CLI..."

  # Executa gh auth status --show-token e captura saída
  if ! token_output=$(gh auth status --show-token 2>&1); then
    log_error "Falha ao obter status de autenticação do GitHub"
    log_debug "Saída do comando: ${token_output}"
    _log_func_exit_fail "extract_github_token" "1"
    return 1
  fi

  # Extrai o token usando grep e awk
  token=$(echo "${token_output}" | grep -E "^\s*- Token:" | awk '{print $3}')

  if [[ -z "${token}" ]]; then
    log_error "Não foi possível extrair o token da saída do gh auth status"
    log_debug "Saída completa: ${token_output}"
    _log_func_exit_fail "extract_github_token" "1"
    return 1
  fi

  # Valida formato do token (deve começar com gho_, ghp_, ou ghs_)
  if [[ ! "${token}" =~ ^gh[ops]_[A-Za-z0-9_]{36,}$ ]]; then
    log_warning "Token não segue formato esperado do GitHub: ${token:0:8}..."
  fi

  log_success "Token extraído com sucesso: ${token:0:8}...${token: -4}"
  echo "${token}"
  _log_func_exit_ok "extract_github_token"
  return 0
}

# Configura a variável GITHUB_TOKEN
setup_github_token() {
  _log_func_enter "setup_github_token"
  local token="$1"

  if [[ -z "${token}" ]]; then
    log_error "Token não fornecido para configuração"
    _log_func_exit_fail "setup_github_token" "1"
    return 1
  fi

  # Exporta a variável
  export GITHUB_TOKEN="${token}"

  # Verifica se foi configurada corretamente
  if [[ "${GITHUB_TOKEN}" == "${token}" ]]; then
    log_success "GITHUB_TOKEN configurado: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"
    log_info "Variável disponível para uso com Aider e outras ferramentas"
    _log_func_exit_ok "setup_github_token"
    return 0
  else
    log_error "Falha ao configurar GITHUB_TOKEN"
    _log_func_exit_fail "setup_github_token" "1"
    return 1
  fi
}

# Valida a configuração do token
validate_token_setup() {
  _log_func_enter "validate_token_setup"

  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    log_error "GITHUB_TOKEN não está configurado"
    _log_func_exit_fail "validate_token_setup" "1"
    return 1
  fi

  log_info "Validando token configurado..."

  # Testa o token fazendo uma chamada simples à API
  log_debug "Testando token com: gh api user"
  local api_result
  if api_result=$(gh api user 2>&1); then
    log_success "Token válido e funcionando"
    log_info "Pronto para usar com: aider, gh api, etc."
    _log_func_exit_ok "validate_token_setup"
    return 0
  else
    log_error "Token configurado mas não está funcionando"
    log_debug "Erro da API: ${api_result}"
    log_info "Verifique se o token tem as permissões necessárias"
    _log_func_exit_fail "validate_token_setup" "1"
    return 1
  fi
}

# Mostra informações sobre o uso
show_usage_info() {
  _log_func_enter "show_usage_info"

  log_section "INFORMAÇÕES DE USO"
  log_info "Token configurado com sucesso!"
  log_info ""
  log_info "Próximos passos:"
  log_info "  1. Para usar com Aider:"
  log_info "     $ aider"
  log_info ""
  log_info "  2. Para persistir em nova sessão:"
  log_info "     $ echo 'export GITHUB_TOKEN=\"\${GITHUB_TOKEN}\"' >> ~/.bashrc"
  log_info ""
  log_info "  3. Para usar em scripts:"
  log_info "     $ source ./setup-github-token.sh"
  log_info ""
  log_info "Variáveis configuradas:"
  log_info "  GITHUB_TOKEN: ${GITHUB_TOKEN:0:8}...${GITHUB_TOKEN: -4}"
  log_info "  OPENAI_API_KEY: ${OPENAI_API_KEY:0:8}...${OPENAI_API_KEY: -4}"
  log_info "  OPENAI_API_BASE: ${OPENAI_API_BASE}"
  echo ""
  log_info "✅ Pronto para uso com Aider!"
  log_info "Execute: aider --help"

  _log_func_exit_ok "show_usage_info"
  return 0
}

################################################################################
# Função Main
################################################################################

main() {
  _log_func_enter "main"

  log_section "CONFIGURAÇÃO DO GITHUB TOKEN"
  log_info "Iniciando configuração do token do GitHub para Aider..."

  # Verifica autenticação do GitHub CLI
  if ! check_gh_auth; then
    log_error "Falha na verificação do GitHub CLI"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Extrai o token diretamente com limpeza adequada
  local token
  local raw_token

  # Primeiro tenta usar gh auth token (método mais limpo)
  if raw_token=$(gh auth token 2>/dev/null); then
    # Remove apenas caracteres de controle e espaços, mantém caracteres válidos do token
    token=$(echo "${raw_token}" | tr -d '\n\r[:space:]')
  else
    # Fallback para gh auth status --show-token
    log_info "Usando método alternativo para obter token..."
    if ! token=$(extract_github_token); then
      log_error "Falha ao extrair token do GitHub"
      log_info "Execute: gh auth login"
      _log_func_exit_fail "main" "1"
      exit 1
    fi
  fi

  if [[ -z "${token}" ]]; then
    log_error "Token obtido está vazio"
    log_info "Execute: gh auth login"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Valida formato do token (deve começar com gho_, ghp_, ou ghs_)
  if [[ ! "${token}" =~ ^gh[ops]_[A-Za-z0-9_]{36,}$ ]]; then
    log_warning "Token não segue formato esperado do GitHub: ${token:0:8}..."
    log_info "Formato esperado: gho_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  fi

  log_info "Token extraído e limpo: ${token:0:8}...${token: -4}"

  # Configura também OPENAI_API_KEY e OPENAI_API_BASE para Aider
  export OPENAI_API_KEY="${token}"
   export OPENAI_API_BASE="https://api.githubcopilot.com"

  log_success "Variáveis configuradas para Aider:"
  log_info "  OPENAI_API_KEY: ${token:0:8}...${token: -4}"
  log_info "  OPENAI_API_BASE: ${OPENAI_API_BASE}"  # Configura a variável
  if ! setup_github_token "${token}"; then
    log_error "Falha ao configurar GITHUB_TOKEN"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Valida a configuração
  if ! validate_token_setup; then
    log_error "Falha na validação do token"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Mostra informações de uso
  show_usage_info

  log_success "Configuração concluída com sucesso!"
  _log_func_exit_ok "main"
  return 0
}

# Executar main se script for chamado diretamente OU sourced sem argumentos
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ $# -eq 0 && "${BASH_SOURCE[0]}" != "${0}" ]]; then
  main "$@"
fi
