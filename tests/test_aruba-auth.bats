#!/usr/bin/env bats
# test_aruba-auth.bats
# Tests for aruba-auth.sh script

load test_helper

setup() {
  # Source commons.sh first to get logging functions
  source "${PROJECT_ROOT}/commons.sh"
  setup_mock_env
}

teardown() {
  teardown_mock_env
}

@test "aruba-auth.sh: Script file exists and is executable" {
  [ -f "${PROJECT_ROOT}/aruba-auth.sh" ]
  [ -x "${PROJECT_ROOT}/aruba-auth.sh" ]
}

@test "aruba-auth.sh: Script has correct shebang" {
  run head -n 1 "${PROJECT_ROOT}/aruba-auth.sh"
  [[ "$output" == "#!/bin/bash" ]] || [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "aruba-auth.sh: Script sources commons.sh" {
  run grep -q "source.*commons.sh" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script contains required functions" {
  # Check for main authentication function
  run grep -Eq "function.*auth|^[a-z_]+.*\(\).*\{" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script validates required environment variables" {
  # Check if script validates ARUBA_HOST or similar
  run grep -Eq "ARUBA_HOST|ARUBA_USER|ARUBA_PASSWORD" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script has logging statements" {
  # Check for log function calls
  run grep -E "log_(info|error|success|warning|debug)" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script handles errors properly" {
  # Check for error handling
  run grep -q "return 1\|exit 1" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script uses proper exit codes" {
  # Check for return statements
  run grep -E "return [0-9]" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script has proper documentation" {
  # Check for description comments
  run grep -q "^# Description:\|^# Script:" "${PROJECT_ROOT}/aruba-auth.sh"
  [ "$status" -eq 0 ]
}

@test "aruba-auth.sh: Script follows naming conventions" {
  # Verify script name follows kebab-case
  SCRIPT_NAME="aruba-auth.sh"
  [[ "$SCRIPT_NAME" =~ ^[a-z]+(-[a-z]+)*\.sh$ ]]
}
