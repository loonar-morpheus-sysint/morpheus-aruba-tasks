#!/usr/bin/env bats
################################################################################
# Testes BATS para setup-github-token.sh
# Valida se o script segue os padrões estabelecidos no AGENTS.md
################################################################################

# Carrega helper comum
load test_helper

# Variáveis do script sendo testado
SCRIPT_NAME="setup-github-token.sh"
SCRIPT_PATH="${BATS_TEST_DIRNAME}/../${SCRIPT_NAME}"

################################################################################
# Testes de Estrutura do Script
################################################################################

@test "${SCRIPT_NAME}: Script file exists and is executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}

@test "${SCRIPT_NAME}: Script has correct shebang" {
  run head -1 "${SCRIPT_PATH}"
  [[ "$output" =~ ^#!/bin/bash$ || "$output" =~ ^#!/usr/bin/env\ bash$ ]]
}

@test "${SCRIPT_NAME}: Script sources commons.sh" {
  run grep -E "source.*commons\.sh" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script has required header format" {
  run grep -E "^# Script: ${SCRIPT_NAME}$" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  run grep -E "^# Description: " "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Testes de Funções
################################################################################

@test "${SCRIPT_NAME}: Script has main function" {
  run grep -E "^main\(\)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script contains token extraction function" {
  run grep -E "(extract_github_token|get_token|setup_github_token)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script has GitHub CLI validation" {
  run grep -E "(command -v gh|check_gh_auth|gh auth status)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Testes de Logging
################################################################################

@test "${SCRIPT_NAME}: Script has logging statements" {
  run grep -E "(log_info|log_error|log_success|log_warning)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script has function entry/exit logging" {
  run grep -E "_log_func_enter" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  run grep -E "_log_func_exit_(ok|fail)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Testes de Validação
################################################################################

@test "${SCRIPT_NAME}: Script validates dependencies" {
  run grep -E "(command -v|which)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script handles errors properly" {
  run grep -E "(return 1|exit 1)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script uses proper exit codes" {
  run grep -E "(return 0|exit 0)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Testes de Padrões
################################################################################

@test "${SCRIPT_NAME}: Script has proper documentation" {
  # Verifica se há comentários explicativos
  run grep -E "^#" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  # Verifica se há seção de descrição detalhada
  run grep -E "DESCRIÇÃO DETALHADA" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script follows naming conventions" {
  # Verifica se o nome do arquivo segue o padrão kebab-case
  [[ "${SCRIPT_NAME}" =~ ^[a-z]([a-z0-9-]*[a-z0-9])?\.sh$ ]]
}

@test "${SCRIPT_NAME}: Script has sourcing protection" {
  run grep -A1 -E 'if.*BASH_SOURCE.*0.*0' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "main" ]]
}

################################################################################
# Testes Específicos do Script
################################################################################

@test "${SCRIPT_NAME}: Script extracts GitHub token correctly" {
  run grep -E "(gh auth status --show-token|grep.*Token|awk)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script validates token format" {
  run grep -E "(gh[ops]_|token.*format)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script exports GITHUB_TOKEN variable" {
  run grep -E "(export GITHUB_TOKEN|GITHUB_TOKEN=)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "${SCRIPT_NAME}: Script validates token functionality" {
  run grep -E "(gh api|validate.*token)" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}
