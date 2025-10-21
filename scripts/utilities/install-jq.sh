#!/usr/bin/env bash
################################################################################
# Script: install-jq.sh
# Description: Ensure 'jq' is installed. If missing, attempt to download the
#              official jq binary and make it available in PATH for the current
#              session. The installer prefers /opt/morpheus/.local/bin when
#              present, otherwise /usr/local/bin, and falls back to
#              $HOME/.local/bin when necessary.
################################################################################

# shellcheck disable=SC2034
INSTALLER_NAME="install-jq"

# Provide lightweight log function fallbacks when commons.sh wasn't sourced
if ! declare -f log_info >/dev/null 2>&1; then
    log_info() { echo "[INFO] $*"; }
fi
if ! declare -f log_warn >/dev/null 2>&1; then
    log_warn() { echo "[WARN] $*"; }
fi
if ! declare -f log_error >/dev/null 2>&1; then
    log_error() { echo "[ERROR] $*" >&2; }
fi
if ! declare -f log_success >/dev/null 2>&1; then
    log_success() { echo "[OK] $*"; }
fi
if ! declare -f _log_func_enter >/dev/null 2>&1; then
    _log_func_enter() { :; }
fi
if ! declare -f _log_func_exit_ok >/dev/null 2>&1; then
    _log_func_exit_ok() { :; }
fi
if ! declare -f _log_func_exit_fail >/dev/null 2>&1; then
    _log_func_exit_fail() { :; }
fi

ensure_jq_installed() {
    _log_func_enter "ensure_jq_installed"

    # Already installed? Allow forcing installation for tests using JQ_INSTALL_FORCE
    if [[ -z "${JQ_INSTALL_FORCE:-}" ]] && command -v jq > /dev/null 2>&1; then
        log_info "jq is already installed at $(command -v jq)"
        _log_func_exit_ok "ensure_jq_installed"
        return 0
    fi

    # Determine install directory
    local jq_dir jq_path download_url
    if [[ -d "/opt/morpheus" ]]; then
        jq_dir="/opt/morpheus/.local/bin"
    else
        jq_dir="/usr/local/bin"
    fi
    jq_path="${jq_dir}/jq"
    download_url="https://github.com/stedolan/jq/releases/latest/download/jq-linux64"

    # Ensure directory exists and is writable (fall back to $HOME/.local/bin if not writable)
    if ! mkdir -p "${jq_dir}" 2>/dev/null || ! touch "${jq_dir}/.write_test" 2>/dev/null; then
        log_warn "Cannot create or write to ${jq_dir}, falling back to ${HOME}/.local/bin"
        jq_dir="${HOME}/.local/bin"
        jq_path="${jq_dir}/jq"
        if ! mkdir -p "${jq_dir}" 2>/dev/null || ! touch "${jq_dir}/.write_test" 2>/dev/null; then
            log_error "Unable to create fallback directory: ${jq_dir}"
            _log_func_exit_fail "ensure_jq_installed" "1"
            return 1
        fi
    fi
    # remove write test file if present
    rm -f "${jq_dir}/.write_test" 2>/dev/null || true

    log_info "Installing jq to ${jq_path}"

    # Download jq using curl (prefer curl, but try wget if curl missing)
    if command -v curl > /dev/null 2>&1; then
        if ! curl -L -sSf -o "${jq_path}" "${download_url}"; then
            log_error "Failed to download jq with curl"
            _log_func_exit_fail "ensure_jq_installed" "1"
            return 1
        fi
    elif command -v wget > /dev/null 2>&1; then
        if ! wget -q -O "${jq_path}" "${download_url}"; then
            log_error "Failed to download jq with wget"
            _log_func_exit_fail "ensure_jq_installed" "1"
            return 1
        fi
    else
        log_error "Neither curl nor wget are available to download jq"
        _log_func_exit_fail "ensure_jq_installed" "1"
        return 1
    fi

    chmod +x "${jq_path}" 2>/dev/null || log_warn "Unable to chmod ${jq_path}"

    # Ensure install dir is on PATH for current session
    if [[ ":$PATH:" != *":$(dirname "${jq_path}"):"* ]]; then
        local jq_dirname
        jq_dirname=$(dirname "${jq_path}")
        export PATH="$PATH:${jq_dirname}"
        log_info "Added $(dirname "${jq_path}") to PATH for current session"
    fi

    # Validate installation
    if command -v jq > /dev/null 2>&1; then
        log_success "jq installed successfully: $(command -v jq)"
        jq --version || true
        _log_func_exit_ok "ensure_jq_installed"
        return 0
    fi

    # If command -v didn't find it, but file exists and is executable, use it directly
    if [[ -x "${jq_path}" ]]; then
        log_success "jq installed to ${jq_path} (not in PATH)"
        _log_func_exit_ok "ensure_jq_installed"
        return 0
    fi

    log_error "jq installation failed"
    _log_func_exit_fail "ensure_jq_installed" "1"
    return 1
}

return 0
