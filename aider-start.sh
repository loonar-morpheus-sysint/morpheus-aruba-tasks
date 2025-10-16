#!/bin/bash
################################################################################
# Script: aider-start.sh
# Description: Inicia Aider com configurações otimizadas para GitHub Copilot
################################################################################
#
# DESCRIÇÃO DETALHADA:
#   Este script configura automaticamente o ambiente e inicia o Aider
#   com configurações otimizadas para GitHub Copilot, incluindo configuração
#   do token e parâmetros de limite de tokens.
#
# USO:
#   ./aider-start.sh
#   ./aider-start.sh commons.sh create-vrf.sh
#
# EXEMPLOS:
#   ./aider-start.sh                    # Inicia Aider vazio
#   ./aider-start.sh AGENTS.md          # Inclui padrões no contexto
#   ./aider-start.sh commons.sh *.sh    # Trabalha com scripts específicos
#
################################################################################

# Carrega biblioteca comum
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

################################################################################
# Funções
################################################################################

# Configura ambiente para GitHub Copilot
setup_copilot_env() {
  _log_func_enter "setup_copilot_env"

  log_info "Configurando ambiente para GitHub Copilot..."

  # Executa script de configuração
  if ! source "${SCRIPT_DIR}/setup-github-token.sh"; then
    log_error "Falha na configuração do token GitHub"
    _log_func_exit_fail "setup_copilot_env" "1"
    return 1
  fi

  log_success "Ambiente configurado com sucesso"
  _log_func_exit_ok "setup_copilot_env"
  return 0
}

# Inicia Aider com configurações otimizadas
start_aider() {
  _log_func_enter "start_aider"
  local files=("$@")

  log_info "Iniciando Aider com GitHub Copilot..."
  log_info "Modelo: gpt-4o-mini (otimizado para limites de token)"

  # Parâmetros otimizados para GitHub Copilot
  local aider_args=(
    "--model" "gpt-4o-mini"
    "--no-auto-commits"
    "--map-tokens" "512"
    "--max-chat-history-tokens" "2000"
    "--no-show-model-warnings"
    "--stream"
    "--dark-mode"
  )

  # Adiciona arquivos se fornecidos
  if [[ ${#files[@]} -gt 0 ]]; then
    log_info "Arquivos no contexto: ${files[*]}"
    aider_args+=("${files[@]}")
  fi

  log_info "Executando: aider ${aider_args[*]}"

  # Executa Aider
  aider "${aider_args[@]}"

  _log_func_exit_ok "start_aider"
  return 0
}

################################################################################
# Função Main
################################################################################

main() {
  _log_func_enter "main"

  log_section "AIDER - GITHUB COPILOT"

  # Configura ambiente
  if ! setup_copilot_env; then
    log_error "Falha na configuração do ambiente"
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Inicia Aider com arquivos fornecidos
  start_aider "$@"

  _log_func_exit_ok "main"
  return 0
}

# Executar main apenas se script for chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
