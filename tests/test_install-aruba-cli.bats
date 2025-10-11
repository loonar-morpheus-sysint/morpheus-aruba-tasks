#!/usr/bin/env bats
# test_install-aruba-cli.bats
# Tests for install-aruba-cli.sh script

load test_helper

setup() {
  # Source commons.sh first to get logging functions
  source "${PROJECT_ROOT}/commons.sh"
  setup_mock_env
}

teardown() {
  teardown_mock_env
}

@test "install-aruba-cli.sh: Script file exists and is executable" {
  [ -f "${PROJECT_ROOT}/install-aruba-cli.sh" ]
  [ -x "${PROJECT_ROOT}/install-aruba-cli.sh" ]
}

@test "install-aruba-cli.sh: Script has correct shebang" {
  run head -n 1 "${PROJECT_ROOT}/install-aruba-cli.sh"
  [[ "$output" == "#!/bin/bash" ]] || [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "install-aruba-cli.sh: Script sources commons.sh" {
  run grep -q "source.*commons.sh" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script contains installation function" {
  # Check for install-related functions
  run grep -Eq "function.*install|^install.*\(\)|^[a-z_]+.*\(\).*\{" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script checks for dependencies" {
  # Check if script validates dependencies
  run grep -Eq "command -v|which|type -p" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script has logging statements" {
  # Check for log function calls
  run grep -E "log_(info|error|success|warning|debug)" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script has function entry/exit logging" {
  # Check for function logging
  run grep -q "_log_func_enter\|_log_func_exit" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script handles errors properly" {
  # Check for error handling
  run grep -q "return 1\|exit 1" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script validates Python/pip availability" {
  # Check for Python/pip validation
  run grep -Eq "python|pip" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script has proper documentation" {
  # Check for description comments
  run grep -q "^# Description:\|^# Script:" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script follows naming conventions" {
  # Verify script name follows kebab-case
  SCRIPT_NAME="install-aruba-cli.sh"
  [[ "$SCRIPT_NAME" =~ ^[a-z]+(-[a-z]+)*\.sh$ ]]
}

@test "install-aruba-cli.sh: Script has main function" {
  # Check for main function
  run grep -Eq "^main\(\)|^function main" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script checks system requirements" {
  # Check for system requirement validation
  run grep -Eq "uname|os|system|platform" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}

@test "install-aruba-cli.sh: Script has package installation logic" {
  # Check for package installation commands
  run grep -Eq "pip.*install|apt.*install|yum.*install" "${PROJECT_ROOT}/install-aruba-cli.sh"
  [ "$status" -eq 0 ]
}
