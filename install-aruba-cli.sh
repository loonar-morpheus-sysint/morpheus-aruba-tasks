#!/bin/bash
################################################################################
# Script: install-aruba-cli.sh
# Description: Script to detect and install Aruba CLI (aoscx) on Ubuntu
# Usage: ./install-aruba-cli.sh
################################################################################

set -e

# Source common functions
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SOURCE_DIR}/commons.sh"

################################################################################
# Functions
################################################################################

# Check if a command exists
check_command() {
    _log_func_enter "check_command"
    local cmd="$1"

    if command -v "${cmd}" &> /dev/null; then
        log_success "Command '${cmd}' is available"
        _log_func_exit_ok "check_command"
        return 0
    else
        log_warning "Command '${cmd}' is not available"
        _log_func_exit_fail "check_command" "1"
        return 1
    fi
}

# Check if aoscx is installed
check_installed() {
    _log_func_enter "check_installed"
    local pkg="$1"

    if command -v "${pkg}" &> /dev/null; then
        log_success "${pkg} is already installed"
        _log_func_exit_ok "check_installed"
        return 0
    else
        log_info "${pkg} is not installed"
        _log_func_exit_fail "check_installed" "1"
        return 1
    fi
}

# Detect operating system
check_os() {
    _log_func_enter "check_os"

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        log_info "Detected OS: ${NAME} ${VERSION}"
        _log_func_exit_ok "check_os"
        echo "${ID}"
        return 0
    else
        log_error "Cannot detect operating system"
        _log_func_exit_fail "check_os" "1"
        return 1
    fi
}

# Install dependencies
install_deps() {
    _log_func_enter "install_deps"
    local os_type="$1"
    shift
    local deps=("$@")

    log_info "Installing dependencies: ${deps[*]}"

    case "${os_type}" in
        ubuntu|debian)
            log_info "Using apt package manager"
            sudo apt-get update || {
                log_error "Failed to update package list"
                _log_func_exit_fail "install_deps" "1"
                return 1
            }
            sudo apt-get install -y "${deps[@]}" || {
                log_error "Failed to install dependencies"
                _log_func_exit_fail "install_deps" "1"
                return 1
            }
            ;;
        fedora|rhel|centos)
            log_info "Using dnf/yum package manager"
            sudo dnf install -y "${deps[@]}" 2>/dev/null || \
            sudo yum install -y "${deps[@]}" || {
                log_error "Failed to install dependencies"
                _log_func_exit_fail "install_deps" "1"
                return 1
            }
            ;;
        *)
            log_error "Unsupported operating system: ${os_type}"
            _log_func_exit_fail "install_deps" "1"
            return 1
            ;;
    esac

    log_success "Dependencies installed successfully"
    _log_func_exit_ok "install_deps"
    return 0
}

# Verify installation
verify_installation() {
    _log_func_enter "verify_installation"
    local pkg="$1"

    log_info "Verifying ${pkg} installation..."

    if command -v "${pkg}" &> /dev/null; then
        log_success "${pkg} is installed successfully"
        log_info "Version information:"
        "${pkg}" --version || "${pkg}" -v || log_warning "Could not get version info"
        _log_func_exit_ok "verify_installation"
        return 0
    else
        log_error "${pkg} installation failed"
        _log_func_exit_fail "verify_installation" "1"
        return 1
    fi
}

# Main script
main() {
    _log_func_enter "main"

    log_section "ARUBA CLI INSTALLATION"
    log_info "Checking for Aruba CLI installation..."

    # Check if aoscx CLI is already installed
    if check_installed "aoscx"; then
        log_info "Aruba CLI (aoscx) is already installed."
        aoscx --version || log_warning "Could not retrieve version"
        _log_func_exit_ok "main"
        exit 0
    fi

    log_info "Aruba CLI not found. Installing..."

    # Detect operating system
    if ! os_type=$(check_os); then
        log_error "Failed to detect operating system"
        _log_func_exit_fail "main" "1"
        exit 1
    fi

    log_info "Detected OS: ${os_type}"

    # Check for required commands
    log_info "Checking for required dependencies..."

    if ! check_command "python3"; then
        log_warning "python3 not found, will install"
    fi

    if ! check_command "pip3"; then
        log_warning "pip3 not found, will install"
    fi

    # Install dependencies (python3 and pip3)
    if ! install_deps "${os_type}" python3 python3-pip; then
        log_error "Failed to install dependencies"
        _log_func_exit_fail "main" "1"
        exit 1
    fi

    # Install Aruba CLI using pip
    log_info "Installing Aruba aoscx CLI via pip..."
    if sudo pip3 install pyaoscx; then
        log_success "pyaoscx package installed successfully"
    else
        log_error "Failed to install pyaoscx package"
        _log_func_exit_fail "main" "1"
        exit 1
    fi

    # Verify installation
    if ! verify_installation "aoscx"; then
        log_error "Installation verification failed"
        _log_func_exit_fail "main" "1"
        exit 1
    fi

    log_success "Installation complete!"
    _log_func_exit_ok "main"
    exit 0
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
