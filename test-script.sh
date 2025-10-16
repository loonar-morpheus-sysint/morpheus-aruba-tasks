#!/bin/bash
################################################################################
# Script: test-script.sh
# Description: Simple script that echoes 'Hello World'
################################################################################
#
# Descrição detalhada (opcional)
# Este script é um exemplo simples que demonstra a estrutura básica de um script.
#
################################################################################

# Carrega biblioteca comum (deve ser a primeira linha funcional)
source "$(dirname "${BASH_SOURCE[0]}")/commons.sh"

main() {
  _log_func_enter "main"

  echo "Hello World"

  _log_func_exit_ok "main"
  return 0
}

# Proteção: executa main() apenas se script for chamado diretamente (não sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
