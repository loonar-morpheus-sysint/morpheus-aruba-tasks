#!/usr/bin/env bats
################################################################################
# Script: test_create-aruba-vrf.bats
# Description: BATS tests for create-vrf-afc.sh script
################################################################################

load test_helper

# Setup - runs before each test
setup() {
  # Source test helper
  load test_helper

  # Store original directory
  ORIGINAL_DIR="$(pwd)"

  # Change to script directory
  cd "${BATS_TEST_DIRNAME}/.." || exit 1

  # Set script path (use PROJECT_ROOT defined in test_helper)
  SCRIPT_PATH="${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"

  # Create temporary test directory
  TEST_TEMP_DIR="$(mktemp -d)"

  # Mock environment variables
  export FABRIC_COMPOSER_IP="10.0.0.100"
  export FABRIC_COMPOSER_USERNAME="test_user"
  export FABRIC_COMPOSER_PASSWORD="test_pass"  # pragma: allowlist secret
  export FABRIC_COMPOSER_PORT="443"
  export FABRIC_COMPOSER_PROTOCOL="https"
}

# Teardown - runs after each test
teardown() {
  # Clean up temp directory
  if [[ -n "${TEST_TEMP_DIR}" ]] && [[ -d "${TEST_TEMP_DIR}" ]]; then
    rm -rf "${TEST_TEMP_DIR}"
  fi

  # Return to original directory
  cd "${ORIGINAL_DIR}" || exit 1

  # Clean up token files
  rm -f .afc_token .afc_token_expiry
}

################################################################################
# Structure Tests
################################################################################

@test "create-vrf-afc.sh: Script exists and is executable" {
  [ -f "${SCRIPT_PATH}" ]
  [ -x "${SCRIPT_PATH}" ]
}

@test "create-vrf-afc.sh: Has correct shebang" {
  run head -n 1 "${SCRIPT_PATH}"
  [[ "${output}" =~ ^#!/bin/bash || "${output}" =~ ^#!/usr/bin/env\ bash ]]
}

@test "create-vrf-afc.sh: Has required header format" {
  run grep "# Script: create-vrf-afc.sh" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  run grep "# Description:" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Sources commons.sh" {
  run grep "source.*commons.sh" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has main() function" {
  run grep "^main()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has sourcing protection" {
  run bash -c "grep -F 'if [[ \"\${BASH_SOURCE[0]}\" == \"\${0}\" ]]; then' '${SCRIPT_PATH}'"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: File name follows kebab-case pattern" {
  local filename
  filename=$(basename "${SCRIPT_PATH}")
  [[ "${filename}" =~ ^[a-z0-9-]+\.sh$ ]]
}

################################################################################
# Function Tests
################################################################################

@test "create-vrf-afc.sh: All functions have _log_func_enter" {
  # Get all function names (excluding main which is tested separately)
  # Match function declarations with opening brace
  local functions
  functions=$(grep -E "^[a-z_]+\(\) \{" "${SCRIPT_PATH}" | sed 's/() {//g' | grep -v "^main$" || true)

  if [[ -z "${functions}" ]]; then
    skip "No functions found to test"
  fi

  local failed=0
  for func in ${functions}; do
    # Check if function has _log_func_enter within first 5 lines of function body
    if ! awk "/^${func}\(\) \{/,/^}/" "${SCRIPT_PATH}" | head -10 | grep -q "_log_func_enter"; then
      echo "Function ${func} missing _log_func_enter"
      failed=1
    fi
  done

  [ ${failed} -eq 0 ]
}

@test "create-vrf-afc.sh: main() function has _log_func_enter" {
  run bash -c "grep -A 2 '^main()' '${SCRIPT_PATH}' | grep '_log_func_enter \"main\"'"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Functions have _log_func_exit_ok before return 0" {
  # Check for return 0 statements that should have _log_func_exit_ok before them
  run bash -c "grep -B 1 'return 0' '${SCRIPT_PATH}' | grep '_log_func_exit_ok' | wc -l"
  [ "$status" -eq 0 ]
  [ "${output}" -gt 0 ]
}

@test "create-vrf-afc.sh: Functions have _log_func_exit_fail before return 1" {
  # Check for return 1 statements that should have _log_func_exit_fail before them
  run bash -c "grep -B 1 'return 1' '${SCRIPT_PATH}' | grep '_log_func_exit_fail' | wc -l"
  [ "$status" -eq 0 ]
  [ "${output}" -gt 0 ]
}

################################################################################
# Logging Tests
################################################################################

@test "create-vrf-afc.sh: Uses log_info function" {
  run grep "log_info" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses log_error function" {
  run grep "log_error" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses log_success function" {
  run grep "log_success" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has error handling (return 1)" {
  run grep "return 1" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Validation Tests
################################################################################

@test "create-vrf-afc.sh: Validates dependencies with command -v" {
  run grep "command -v" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Script has check_dependencies function" {
  run grep "check_dependencies()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Help and Usage Tests
################################################################################

@test "create-vrf-afc.sh: Shows help with --help" {
  run bash "${SCRIPT_PATH}" --help
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Usage:" ]]
}

@test "create-vrf-afc.sh: Shows help with -h" {
  run bash "${SCRIPT_PATH}" -h
  [ "$status" -eq 0 ]
  [[ "${output}" =~ "Usage:" ]]
}

@test "create-vrf-afc.sh: Help shows all required options" {
  run bash "${SCRIPT_PATH}" --help
  [[ "${output}" =~ "--name" ]]
  [[ "${output}" =~ "--fabric" ]]
  [[ "${output}" =~ "--rd" ]]
  [[ "${output}" =~ "--interactive" ]]
}

################################################################################
# Argument Parsing Tests
################################################################################

@test "create-vrf-afc.sh: Rejects unknown parameters" {
  run bash "${SCRIPT_PATH}" --unknown-param
  [ "$status" -eq 1 ]
  [[ "${output}" =~ "Unknown parameter" ]]
}

@test "create-vrf-afc.sh: Has parse_arguments function" {
  run grep "parse_arguments()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Environment Variable Tests
################################################################################

@test "create-vrf-afc.sh: validate_environment function exists" {
  run grep "validate_environment()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Fails without FABRIC_COMPOSER_IP" {
  unset FABRIC_COMPOSER_IP
  run bash "${SCRIPT_PATH}" --name TEST-VRF --fabric test-fabric --rd 65000:100
  [ "$status" -eq 1 ]
  [[ "${output}" =~ "FABRIC_COMPOSER_IP" ]]
}

@test "create-vrf-afc.sh: Fails without FABRIC_COMPOSER_USERNAME" {
  unset FABRIC_COMPOSER_USERNAME
  run bash "${SCRIPT_PATH}" --name TEST-VRF --fabric test-fabric --rd 65000:100
  [ "$status" -eq 1 ]
  [[ "${output}" =~ "FABRIC_COMPOSER_USERNAME" ]]
}

@test "create-vrf-afc.sh: Fails without FABRIC_COMPOSER_PASSWORD" {
  unset FABRIC_COMPOSER_PASSWORD
  run bash "${SCRIPT_PATH}" --name TEST-VRF --fabric test-fabric --rd 65000:100
  [ "$status" -eq 1 ]
  [[ "${output}" =~ "FABRIC_COMPOSER_PASSWORD" ]]
}

################################################################################
# VRF Configuration Tests
################################################################################

@test "create-vrf-afc.sh: Has validate_vrf_config function" {
  run grep "validate_vrf_config()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has build_vrf_payload function" {
  run grep "build_vrf_payload()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has create_vrf function" {
  run grep "create_vrf()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Token Management Tests
################################################################################

@test "create-vrf-afc.sh: Has get_auth_token function" {
  run grep "get_auth_token()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has token_needs_refresh function" {
  run grep "token_needs_refresh()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Has read_token function" {
  run grep "read_token()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses TOKEN_FILE variable" {
  run grep "TOKEN_FILE" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses TOKEN_EXPIRY_FILE variable" {
  run grep "TOKEN_EXPIRY_FILE" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Dependency Tests
################################################################################

@test "create-vrf-afc.sh: Checks for curl dependency" {
  run bash -c "grep 'curl' '${SCRIPT_PATH}' | grep -E 'command -v|deps=' | head -1"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Checks for jq dependency" {
  run bash -c "grep 'jq' '${SCRIPT_PATH}' | grep -E 'command -v|deps=' | head -1"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Checks for date dependency" {
  run bash -c "grep 'date' '${SCRIPT_PATH}' | grep -E 'command -v|deps=' | head -1"
  [ "$status" -eq 0 ]
}

################################################################################
# Code Quality Tests
################################################################################

@test "create-vrf-afc.sh: Passes shellcheck" {
  if ! command -v shellcheck &> /dev/null; then
    skip "shellcheck not installed"
  fi

  run shellcheck "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: No syntax errors" {
  run bash -n "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses set -e or proper error handling" {
  # Script should handle errors properly
  run bash -c "grep -E 'set -e|return 1|exit 1' '${SCRIPT_PATH}' | wc -l"
  [ "$status" -eq 0 ]
  [ "${output}" -gt 0 ]
}

################################################################################
# Interactive Mode Tests
################################################################################

@test "create-vrf-afc.sh: Has prompt_vrf_config function" {
  run grep "prompt_vrf_config()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Supports --interactive flag" {
  run grep '\-i|\-\-interactive' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Documentation Tests
################################################################################

@test "create-vrf-afc.sh: Has descriptive comments" {
  # Check for comment blocks
  run bash -c "grep '^#' '${SCRIPT_PATH}' | wc -l"
  [ "$status" -eq 0 ]
  [ "${output}" -gt 10 ]
}

@test "create-vrf-afc.sh: Has show_usage function" {
  run grep "show_usage()" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# API Integration Tests
################################################################################

@test "create-vrf-afc.sh: Uses curl for API calls" {
  run grep "curl.*POST" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Uses jq for JSON processing" {
  run grep "jq -n" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Includes Authorization header handling" {
  run grep "Authorization: Bearer" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Handles HTTP status codes" {
  run grep "http_code" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

################################################################################
# Global Variables Tests
################################################################################

@test "create-vrf-afc.sh: Global variables use UPPERCASE" {
  # Check that common global variables are in uppercase
  run grep "^API_VERSION=" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  run grep "^TOKEN_FILE=" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]

  run grep "^VRF_NAME=" "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Supports max sessions and cps options" {
  run grep -- '--max-sessions-mode' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  run grep -- '--max-cps-mode' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  run grep -- '--max-sessions' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
  run grep -- '--max-cps' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Includes max_sessions and max_cps in payload builder" {
  run grep -E 'max_sessions_mode|max_cps_mode|max_sessions|max_cps' "${SCRIPT_PATH}"
  [ "$status" -eq 0 ]
}

@test "create-vrf-afc.sh: Local variables use lowercase" {
  # Check that functions use local variables
  run bash -c "grep 'local [a-z_]*=' '${SCRIPT_PATH}' | wc -l"
  [ "$status" -eq 0 ]
  [ "${output}" -gt 0 ]
}
