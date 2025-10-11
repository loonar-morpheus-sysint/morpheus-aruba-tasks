#!/bin/bash
################################################################################
# Script: validate-aider.sh
# Description: Valida instalação e configuração do Aider AI
################################################################################
#
# Este script verifica se o Aider está corretamente instalado e configurado
# para funcionar com o GitHub Copilot como backend LLM.
#
# USO:
#   ./validate-aider.sh
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

################################################################################
# Funções de Validação
################################################################################

# Valida se Aider está instalado
check_aider_installation() {
  _log_func_enter "check_aider_installation"

  log_info "Verificando instalação do Aider..."

  if command -v aider &> /dev/null; then
    local version
    version=$(aider --version 2>&1 | head -n 1)
    log_success "Aider instalado: ${version}"
    _log_func_exit_ok "check_aider_installation"
    return 0
  else
    log_error "Aider não está instalado"
    log_info "Execute: pip3 install aider-install"
    _log_func_exit_fail "check_aider_installation" "1"
    return 1
  fi
}

# Valida variáveis de ambiente
check_environment_variables() {
  _log_func_enter "check_environment_variables"

  log_info "Verificando variáveis de ambiente..."

  local all_ok=0

  # OPENAI_API_BASE
  if [[ -n "${OPENAI_API_BASE:-}" ]]; then
    log_success "OPENAI_API_BASE: ${OPENAI_API_BASE}"
  else
    log_error "OPENAI_API_BASE não configurado"
    log_info "Deveria ser: https://api.githubcopilot.com"
    all_ok=1
  fi

  # OPENAI_API_KEY
  if [[ -n "${OPENAI_API_KEY:-}" ]]; then
    log_success "OPENAI_API_KEY: configurado (valor oculto por segurança)"
  else
    log_warning "OPENAI_API_KEY não configurado"
    log_info "Configure com: export OPENAI_API_KEY=\$(gh auth token)"
    all_ok=1
  fi

  # GITHUB_TOKEN (alternativa)
  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    log_success "GITHUB_TOKEN: configurado (pode ser usado como OPENAI_API_KEY)"
  fi

  # AIDER_MODEL
  if [[ -n "${AIDER_MODEL:-}" ]]; then
    log_success "AIDER_MODEL: ${AIDER_MODEL}"
  else
    log_warning "AIDER_MODEL não configurado (usará padrão)"
  fi

  if [[ ${all_ok} -eq 0 ]]; then
    _log_func_exit_ok "check_environment_variables"
    return 0
  else
    _log_func_exit_fail "check_environment_variables" "1"
    return 1
  fi
}

# Valida GitHub CLI e autenticação
check_github_auth() {
  _log_func_enter "check_github_auth"

  log_info "Verificando autenticação GitHub..."

  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) não encontrado"
    _log_func_exit_fail "check_github_auth" "1"
    return 1
  fi

  if gh auth status &> /dev/null; then
    log_success "GitHub CLI autenticado"

    # Mostra informações do usuário
    local user
    user=$(gh api user -q .login 2>/dev/null)
    if [[ -n "${user}" ]]; then
      log_info "Usuário GitHub: ${user}"
    fi

    _log_func_exit_ok "check_github_auth"
    return 0
  else
    log_warning "GitHub CLI não autenticado"
    log_info "Execute: gh auth login"
    _log_func_exit_fail "check_github_auth" "1"
    return 1
  fi
}

# Valida se Python está disponível
check_python() {
  _log_func_enter "check_python"

  log_info "Verificando Python..."

  if command -v python3 &> /dev/null; then
    local version
    version=$(python3 --version 2>&1)
    log_success "Python instalado: ${version}"

    # Verifica pip
    if command -v pip3 &> /dev/null; then
      local pip_version
      pip_version=$(pip3 --version 2>&1 | head -n 1)
      log_success "pip instalado: ${pip_version}"
      _log_func_exit_ok "check_python"
      return 0
    else
      log_error "pip3 não encontrado"
      _log_func_exit_fail "check_python" "1"
      return 1
    fi
  else
    log_error "Python3 não encontrado"
    _log_func_exit_fail "check_python" "1"
    return 1
  fi
}

# Testa conectividade com GitHub Copilot API
test_api_connectivity() {
  _log_func_enter "test_api_connectivity"

  log_info "Testando conectividade com GitHub Copilot API..."

  if [[ -z "${OPENAI_API_BASE:-}" ]]; then
    log_warning "OPENAI_API_BASE não configurado, pulando teste"
    _log_func_exit_ok "test_api_connectivity"
    return 0
  fi

  local api_url="${OPENAI_API_BASE}/models"

  if curl -s -o /dev/null -w "%{http_code}" "${api_url}" | grep -q "200\|401"; then
    log_success "API acessível em: ${OPENAI_API_BASE}"
    _log_func_exit_ok "test_api_connectivity"
    return 0
  else
    log_warning "Não foi possível acessar a API"
    log_info "URL testada: ${api_url}"
    _log_func_exit_fail "test_api_connectivity" "1"
    return 1
  fi
}

# Mostra guia de resolução de problemas
show_troubleshooting() {
  _log_func_enter "show_troubleshooting"

  log_section "GUIA DE RESOLUÇÃO DE PROBLEMAS"

  echo ""
  echo "📋 Problemas Comuns e Soluções:"
  echo ""
  echo "1. Aider não instalado:"
  echo "   → pip3 install aider-install"
  echo ""
  echo "2. OPENAI_API_KEY não configurado:"
  echo "   → export OPENAI_API_KEY=\$(gh auth token)"
  echo "   → Ou configure GITHUB_TOKEN antes de abrir o DevContainer"
  echo ""
  echo "3. GitHub CLI não autenticado:"
  echo "   → gh auth login"
  echo ""
  echo "4. GitHub Copilot não disponível:"
  echo "   → Verifique sua assinatura em: https://github.com/settings/copilot"
  echo ""
  echo "5. Variáveis de ambiente não persistentes:"
  echo "   → Adicione ao ~/.bashrc ou ~/.zshrc"
  echo "   → Ou configure no devcontainer.json (containerEnv)"
  echo ""
  echo "📚 Documentação completa: AIDER_SETUP.md"
  echo ""

  _log_func_exit_ok "show_troubleshooting"
  return 0
}

################################################################################
# Função Main
################################################################################

main() {
  _log_func_enter "main"

  log_section "VALIDAÇÃO DO AIDER AI"

  local errors=0

  # Executa validações
  check_python || ((errors++))
  echo ""

  check_aider_installation || ((errors++))
  echo ""

  check_environment_variables || ((errors++))
  echo ""

  check_github_auth || ((errors++))
  echo ""

  test_api_connectivity || ((errors++))
  echo ""

  # Resultado final
  log_section "RESULTADO DA VALIDAÇÃO"

  if [[ ${errors} -eq 0 ]]; then
    log_success "✅ Todas as validações passaram!"
    log_info "Aider está pronto para uso"
    echo ""
    log_info "Para começar, execute: aider"
    log_info "Para ajuda: aider --help"
    log_info "Para documentação: cat AIDER_SETUP.md"
    _log_func_exit_ok "main"
    exit 0
  else
    log_error "❌ ${errors} validação(ões) falharam"
    echo ""
    show_troubleshooting
    _log_func_exit_fail "main" "1"
    exit 1
  fi
}

# Executar main apenas se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
