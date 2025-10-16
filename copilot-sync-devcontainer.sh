#!/bin/bash
################################################################################
# Script: copilot-sync-devcontainer.sh
# Description: Aciona o GitHub Copilot CLI para atualizar arquivos Markdown/documentação relacionados ao devcontainer.json e faz commit automático.
################################################################################
#
# Este script utiliza a GitHub Copilot CLI (gh copilot) para:
#   - Ler o devcontainer.json
#   - Solicitar ao Copilot a atualização dos arquivos Markdown/documentação relacionados
#   - Redigir os textos, alterar os arquivos e fazer commit no repositório
#
# USO:
#   ./copilot-sync-devcontainer.sh
#
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

main() {
  _log_func_enter "main"
  log_section "COPILOT SYNC DEVCONTAINER"
  log_info "Acionando GitHub Copilot CLI para sincronizar arquivos relacionados ao devcontainer.json..."

  # Verifica se gh copilot está instalado
  if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) não está instalado. Instale antes de continuar."
    _log_func_exit_fail "main" "1"
    exit 1
  fi

  # Solicita ao Copilot a tarefa de sincronização
  gh copilot suggest --title "Sincronizar arquivos relacionados ao devcontainer.json" \
    --body "Leia o arquivo .devcontainer/devcontainer.json e atualize todos os arquivos Markdown/documentação relacionados (.devcontainer/Dockerfile, .devcontainer/post-create.sh, SETUP.md, SETUP_SUMMARY.md, THIRDPARTY.md, validate-aider.sh, verify-setup.sh). Redija os textos, altere os arquivos conforme necessário e faça commit das alterações no repositório. Garanta que instruções, dependências, extensões e features estejam consistentes em todos os pontos do projeto. Documente as mudanças relevantes." \
    --commit "Sync: Atualização dos arquivos relacionados ao devcontainer.json"

  log_success "Solicitação enviada ao Copilot CLI. Aguarde a execução e revisão das alterações."
  _log_func_exit_ok "main"
  exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
