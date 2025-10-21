#!/usr/bin/env bash
################################################################################
# Script: install-jq.sh
# Description: Helper to detect and install `jq` if missing. Provides
#              ensure_jq_installed() for scripts to call before using jq.
################################################################################

set -euo pipefail

# Attempt to source logging helpers if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${SCRIPT_DIR}/lib/commons.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/lib/commons.sh"
else
  # Minimal logging fallback
  log_info() { echo "[INFO] $*"; }
  log_warn() { echo "[WARN] $*"; }
  log_error() { echo "[ERROR] $*"; }
  log_debug() { echo "[DEBUG] $*"; }
  _log_func_enter() { :; }
  _log_func_exit_ok() { :; }
  _log_func_exit_fail() { :; }
fi

ensure_jq_installed() {
  _log_func_enter "ensure_jq_installed"

  if command -v jq >/dev/null 2>&1; then
    log_debug "jq is already installed"
    _log_func_exit_ok "ensure_jq_installed"
    return 0
  fi

  log_info "jq not found. Attempting to install..."

  # Detect package manager
  PM=""
  if command -v apt-get >/dev/null 2>&1; then
    PM="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
  elif command -v yum >/dev/null 2>&1; then
    PM="yum"
  elif command -v apk >/dev/null 2>&1; then
    PM="apk"
  elif command -v brew >/dev/null 2>&1; then
    PM="brew"
  fi

  # Try package manager install first (non-interactive only)
  if [[ -n "${PM}" ]]; then
    log_info "Detected package manager: ${PM}. Trying to install jq via package manager (non-interactive)."

    # Check for privilege to run sudo without a password
    local can_sudo_noninteractive=0
    if [[ $(id -u) -eq 0 ]]; then
      can_sudo_noninteractive=1
    elif command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
      can_sudo_noninteractive=1
    fi

    if [[ ${can_sudo_noninteractive} -ne 1 && "${PM}" != "brew" && "${PM}" != "apk" ]]; then
      log_warn "Non-interactive package installation not permitted (sudo requires password). Skipping package manager install."
    else
      case "${PM}" in
        apt)
          if [[ ${can_sudo_noninteractive} -eq 1 ]]; then
            log_info "Running apt-get non-interactively"
            if [[ $(id -u) -ne 0 ]]; then
              if sudo -n apt-get update -qq && sudo -n DEBIAN_FRONTEND=noninteractive apt-get install -y jq; then
                return 0
              fi
            else
              if apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get install -y jq; then
                return 0
              fi
            fi
          fi
          ;;
        dnf)
          if [[ ${can_sudo_noninteractive} -eq 1 ]]; then
            if [[ $(id -u) -ne 0 ]]; then
              if sudo -n dnf install -y jq; then
                return 0
              fi
            else
              if dnf install -y jq; then
                return 0
              fi
            fi
          fi
          ;;
        yum)
          if [[ ${can_sudo_noninteractive} -eq 1 ]]; then
            if [[ $(id -u) -ne 0 ]]; then
              if sudo -n yum install -y jq; then
                return 0
              fi
            else
              if yum install -y jq; then
                return 0
              fi
            fi
          fi
          ;;
        apk)
          if [[ ${can_sudo_noninteractive} -eq 1 ]]; then
            if [[ $(id -u) -ne 0 ]]; then
              if sudo -n apk add --no-cache jq; then
                return 0
              fi
            else
              if apk add --no-cache jq; then
                return 0
              fi
            fi
          fi
          ;;
        brew)
          if brew install jq; then
            return 0
          fi
          ;;
      esac
    fi
    log_warn "Package manager install failed or not permitted. Will try binary fallback."
  fi

  # Binary fallback: download jq static binary for Linux x86_64
  OS="$(uname -s)"
  ARCH="$(uname -m)"
  case "${OS}-${ARCH}" in
    Linux-x86_64)
      JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
      ;;
    Linux-aarch64|Linux-arm64)
      # Try distro package first for arm
      JQ_URL=""
      ;;
    Darwin-x86_64|Darwin-arm64)
      JQ_URL="https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64"
      ;;
    *)
      JQ_URL=""
      ;;
  esac

  if [[ -n "${JQ_URL}" ]]; then
    BIN_DIR="/usr/local/bin"
    if [[ ! -w "${BIN_DIR}" ]]; then
      # Avoid duplicate .local when HOME already ends with .local
      if [[ "${HOME}" == */.local ]]; then
        BIN_DIR="${HOME}/bin"
      else
        BIN_DIR="${HOME}/.local/bin"
      fi
      mkdir -p "${BIN_DIR}"
    fi
    TMP_FILE="${BIN_DIR}/jq"
    log_info "Downloading jq from ${JQ_URL} to ${TMP_FILE}"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "${JQ_URL}" -o "${TMP_FILE}" || true
    elif command -v wget >/dev/null 2>&1; then
      wget -qO "${TMP_FILE}" "${JQ_URL}" || true
    fi
    post_install_verify() {
      local exec_path="$1"
      if [[ -x "${exec_path}" ]]; then
        if "${exec_path}" --version >/dev/null 2>&1; then
          log_info "Post-install: ${exec_path} --version => $(${exec_path} --version 2>/dev/null || echo 'unknown')"
          return 0
        fi
      fi
      return 1
    }

    if [[ -f "${TMP_FILE}" ]]; then
      chmod +x "${TMP_FILE}" || true
      export PATH="${BIN_DIR}:${PATH}"
      # Prefer PATH lookup, but verify binary directly if needed
      if command -v jq >/dev/null 2>&1 && post_install_verify "$(command -v jq)"; then
        log_success "jq installed at ${TMP_FILE}"
        _log_func_exit_ok "ensure_jq_installed"
        return 0
      fi
      if post_install_verify "${TMP_FILE}"; then
        # Ensure our tmp file directory is added to PATH
        if [[ ":$PATH:" != *":${BIN_DIR}:"* ]]; then
          export PATH="${BIN_DIR}:${PATH}"
        fi
        log_success "jq installed at ${TMP_FILE}"
        _log_func_exit_ok "ensure_jq_installed"
        return 0
      fi
    fi
  fi

  log_error "Unable to automatically install jq. Please install it manually and re-run the script."
  _log_func_exit_fail "ensure_jq_installed" "1"
  return 1
}

export -f ensure_jq_installed >/dev/null 2>&1 || true

################################################################################
