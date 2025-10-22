#!/usr/bin/env bats
################################################################################
# Script: test_unbound_variables.bats
# Description: Tests to ensure scripts handle unbound variables correctly when
#              using 'set -u' (nounset option). This prevents runtime errors
#              like "token: unbound variable" when variables are referenced
#              before being initialized.
#
# Background:
#   The error "token: unbound variable" occurs when a script uses 'set -u'
#   and tries to reference a variable that was declared but not initialized.
#   Example:
#     local token          # declared but not initialized
#     if [[ -z "${token}" ]]; then  # ERROR with set -u
#
#   Fix:
#     local token=""       # declared and initialized
#     if [[ -z "${token}" ]]; then  # OK
################################################################################

load test_helper

################################################################################
# Test 1: wrapper-create-vrf-afc.sh must initialize token variable
################################################################################

@test "wrapper-create-vrf-afc.sh: token variable initialized in authenticate_afc()" {
    local script="${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/wrapper-create-vrf-afc.sh"

    # Script uses 'set -u', must initialize variables
    grep -q "set -euo pipefail" "${script}"

    # Verify token is initialized as empty string
    grep -A 20 'authenticate_afc()' "${script}" | grep -q 'local.*token=""'
}

################################################################################
# Test 2: create-vrf-afc.sh must initialize token variable
################################################################################

@test "create-vrf-afc.sh: token variable initialized in get_auth_token()" {
    local script="${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"

    # Verify token is initialized as empty string
    grep -A 30 'get_auth_token()' "${script}" | grep -q 'local.*token=""'
}

################################################################################
# Test 3: create-vrf-hybrid.sh must initialize token variable
################################################################################

@test "create-vrf-hybrid.sh: token variable initialized in get_afc_token()" {
    local script="${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh"

    # Verify token is initialized as empty string
    grep -A 30 'get_afc_token()' "${script}" | grep -q 'local.*token=""'
}

################################################################################
# Test 4: Regression test - no uninitialized token in auth functions
################################################################################

@test "Regression: all AFC auth functions initialize token before conditional checks" {
    # This specifically tests for the bug: "main: line 392: token: unbound variable"
    # When using 'set -u', variables must be initialized before conditional checks

    local scripts=(
        "${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/wrapper-create-vrf-afc.sh"
        "${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-afc.sh"
        "${PROJECT_ROOT}/scripts/aruba/vrf/fabric-composer/create-vrf-hybrid.sh"
    )

    for script in "${scripts[@]}"; do
        # If script uses 'set -u' and has token variable declarations
        if grep -q "set -.*u" "${script}"; then
            # Find functions that declare 'token' variable
            local func_bodies
            func_bodies=$(awk '/authenticate_afc\(\)|get_auth_token\(\)|get_afc_token\(\)/,/^}$/' "${script}")

            if echo "${func_bodies}" | grep -q "local.*token"; then
                # Ensure token is initialized (has ="" assignment)
                echo "${func_bodies}" | grep -E 'local.*(token=""|token\s*=\s*"")' || {
                    echo "FAIL: ${script} declares token without initialization"
                    return 1
                }
            fi
        fi
    done
}

################################################################################
# Test 5: Simulate set -u with uninitialized variable
################################################################################

@test "Simulation: uninitialized token causes 'unbound variable' error with set -u" {
    # Create a minimal test script that demonstrates the bug
    local test_script
    test_script=$(mktemp)

    cat > "${test_script}" <<'EOF'
#!/bin/bash
set -euo pipefail

test_uninitialized() {
    local token  # NOT initialized

    # This should fail with "unbound variable"
    if [[ -z "${token}" ]]; then
        echo "This won't print"
    fi
}

test_uninitialized
EOF

    chmod +x "${test_script}"

    # Run should fail with unbound variable error
    run bash "${test_script}"
    rm -f "${test_script}"

    # Should fail (non-zero exit)
    [ "${status}" -ne 0 ]
    # Error message should mention "unbound variable" or "token"
    [[ "${output}" == *"unbound"* ]] || [[ "${output}" == *"token"* ]]
}

################################################################################
# Test 6: Verify fixed version handles initialization correctly
################################################################################

@test "Simulation: initialized token works correctly with set -u" {
    # Create a test script with properly initialized token
    local test_script
    test_script=$(mktemp)

    cat > "${test_script}" <<'EOF'
#!/bin/bash
set -euo pipefail

test_initialized() {
    local token=""  # Properly initialized

    # This should work fine
    if [[ -z "${token}" || "${token}" == "null" ]]; then
        echo "EXPECTED_BEHAVIOR"
        return 0
    fi

    echo "UNEXPECTED"
    return 1
}

test_initialized
EOF

    chmod +x "${test_script}"

    # Run should succeed
    run bash "${test_script}"
    rm -f "${test_script}"

    # Should succeed (exit 0)
    [ "${status}" -eq 0 ]
    [[ "${output}" == *"EXPECTED_BEHAVIOR"* ]]
}
