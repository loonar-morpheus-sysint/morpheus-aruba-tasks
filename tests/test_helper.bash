#!/usr/bin/env bash
# test_helper.bash
# Helper functions for BATS tests

# Define project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT_ROOT

# Load bats-support and bats-assert if available
if [ -d "${PROJECT_ROOT}/tests/test_helper/bats-support" ]; then
  load "test_helper/bats-support/load"
fi

if [ -d "${PROJECT_ROOT}/tests/test_helper/bats-assert" ]; then
  load "test_helper/bats-assert/load"
fi

# Mock environment variables for testing
setup_mock_env() {
  export ARUBA_HOST="test-switch.example.com"
  export ARUBA_USER="testuser"
  export ARUBA_PASSWORD="testpassword" # pragma: allowlist secret
  export MORPHEUS_API_URL="https://morpheus.example.com"
  export MORPHEUS_TOKEN="test-token-123" # pragma: allowlist secret
}

# Clean up mock environment
teardown_mock_env() {
  unset ARUBA_HOST
  unset ARUBA_USER
  unset ARUBA_PASSWORD
  unset MORPHEUS_API_URL
  unset MORPHEUS_TOKEN
}

# Check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Create temporary test directory
create_test_dir() {
  TEST_TEMP_DIR="$(mktemp -d)"
  export TEST_TEMP_DIR
}

# Clean up temporary test directory
cleanup_test_dir() {
  if [ -n "${TEST_TEMP_DIR}" ] && [ -d "${TEST_TEMP_DIR}" ]; then
    rm -rf "${TEST_TEMP_DIR}"
  fi
}
