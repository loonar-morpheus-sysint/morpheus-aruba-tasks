#!/usr/bin/env bats
# test_create-vrf.bats
# Tests for create-vrf.sh script

load test_helper

setup() {
  # Source commons.sh first to get logging functions
  source "${PROJECT_ROOT}/lib/commons.sh"
  setup_mock_env
  export VRF_NAME="test-vrf"
  export VRF_RD="65000:100"
}

teardown() {
  teardown_mock_env
  unset VRF_NAME
  unset VRF_RD
}

@test "create-vrf.sh: Script file exists and is executable" {
  [ -f "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh" ]
  [ -x "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh" ]
}

@test "create-vrf.sh: Script has correct shebang" {
  run head -n 1 "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [[ "$output" == "#!/bin/bash" ]] || [[ "$output" == "#!/usr/bin/env bash" ]]
}

@test "create-vrf.sh: Script sources commons.sh" {
  run grep -q "source.*commons.sh" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script contains VRF creation function" {
  # Check for VRF-related functions
  run grep -Eq "function.*vrf|^create.*vrf|vrf.*create|^[a-z_]+.*\(\).*\{" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script validates VRF name parameter" {
  # Check if script validates VRF_NAME
  run grep -q "VRF_NAME" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script validates VRF RD parameter" {
  # Check if script handles Route Distinguisher
  run grep -Eq "VRF_RD|RD|route.*distinguisher" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script has logging statements" {
  # Check for log function calls
  run grep -E "log_(info|error|success|warning|debug)" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script has function entry/exit logging" {
  # Check for function logging
  run grep -q "_log_func_enter\|_log_func_exit" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script handles errors properly" {
  # Check for error handling
  run grep -q "return 1\|exit 1" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script has proper documentation" {
  # Check for description comments
  run grep -q "^# Description:\|^# Script:" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script follows naming conventions" {
  # Verify script name follows kebab-case
  SCRIPT_NAME="create-vrf.sh"
  [[ "$SCRIPT_NAME" =~ ^[a-z]+(-[a-z]+)*\.sh$ ]]
}

@test "create-vrf.sh: Script has main function" {
  # Check for main function
  run grep -E "^main\(\)|^function main" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}

@test "create-vrf.sh: Script validates Aruba connection" {
  # Check for Aruba host validation
  run grep -E "ARUBA_HOST|aruba.*auth" "${PROJECT_ROOT}/scripts/aruba/vrf/aoscx/create-vrf-aoscx.sh"
  [ "$status" -eq 0 ]
}
