#!/bin/bash
################################################################################
# Script: update-devcontainer-sync.sh
# Description: Orienta o usuário a sincronizar todos os arquivos relacionados ao devcontainer.json
################################################################################
#
# Este script lê o devcontainer.json e exibe instruções para revisar e atualizar
# todos os arquivos relacionados à configuração do ambiente de desenvolvimento.
# Use este comando sempre que modificar o devcontainer.json.
#
# ARQUIVOS RELACIONADOS:
#   - .devcontainer/Dockerfile
#   - .devcontainer/post-create.sh
#   - .devcontainer/devcontainer.json
#   - SETUP.md, SETUP_SUMMARY.md
#   - THIRDPARTY.md
#   - validate-aider.sh, verify-setup.sh
#
# USO:
#   ./update-devcontainer-sync.sh
#
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/commons.sh"

show_sync_instructions() {
  _log_func_enter "show_sync_instructions"
  log_section "SINCRONIZAÇÃO DO DEVCONTAINER"
  log_info "Sempre que modificar o devcontainer.json, revise e atualize os arquivos relacionados:"
  echo "\nArquivos a revisar e sincronizar:\n"
  echo "  - .devcontainer/Dockerfile"
  echo "  - .devcontainer/post-create.sh"
  echo "  - .devcontainer/devcontainer.json"
  echo "  - SETUP.md, SETUP_SUMMARY.md"
  echo "  - THIRDPARTY.md"
  echo "  - validate-aider.sh, verify-setup.sh"
  echo "\nGaranta que instruções, dependências, extensões e features estejam consistentes em todos os pontos do projeto."
  echo "Sempre documente as mudanças relevantes nos arquivos de referência e instrução."
  _log_func_exit_ok "show_sync_instructions"
  return 0
}

main() {
  _log_func_enter "main"
  log_info "Lendo devcontainer.json..."
  if [[ -f "${SCRIPT_DIR}/.devcontainer/devcontainer.json" ]]; then
    jq '.' "${SCRIPT_DIR}/.devcontainer/devcontainer.json" | head -20
    log_success "devcontainer.json lido com sucesso."
  else
    log_error "Arquivo .devcontainer/devcontainer.json não encontrado."
  fi
  show_sync_instructions
  _log_func_exit_ok "main"
  exit 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
