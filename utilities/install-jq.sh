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

  # Try package manager install first
  if [[ -n "${PM}" ]]; then
    log_info "Detected package manager: ${PM}. Trying to install jq via package manager."
    case "${PM}" in
      apt)
        if [[ $(id -u) -ne 0 && -n $(command -v sudo) ]]; then
          sudo apt-get update && sudo apt-get install -y jq && return 0 || true
        else
          apt-get update && apt-get install -y jq && return 0 || true
        fi
        ;;
      dnf)
        if [[ $(id -u) -ne 0 && -n $(command -v sudo) ]]; then
          sudo dnf install -y jq && return 0 || true
        else
          dnf install -y jq && return 0 || true
        fi
        ;;
      yum)
        if [[ $(id -u) -ne 0 && -n $(command -v sudo) ]]; then
          sudo yum install -y jq && return 0 || true
        else
          yum install -y jq && return 0 || true
        fi
        ;;
      apk)
        if [[ $(id -u) -ne 0 && -n $(command -v sudo) ]]; then
          sudo apk add --no-cache jq && return 0 || true
        else
          apk add --no-cache jq && return 0 || true
        fi
        ;;
      brew)
        brew install jq && return 0 || true
        ;;
    esac
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
      BIN_DIR="${HOME}/.local/bin"
      mkdir -p "${BIN_DIR}"
    fi
    TMP_FILE="${BIN_DIR}/jq"
    log_info "Downloading jq from ${JQ_URL} to ${TMP_FILE}"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "${JQ_URL}" -o "${TMP_FILE}" || true
    elif command -v wget >/dev/null 2>&1; then
      wget -qO "${TMP_FILE}" "${JQ_URL}" || true
    fi
    if [[ -f "${TMP_FILE}" ]]; then
      chmod +x "${TMP_FILE}" || true
      export PATH="${BIN_DIR}:${PATH}"
      if command -v jq >/dev/null 2>&1; then
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
