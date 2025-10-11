#!/bin/bash
# commons.sh - Reusable functions for Aruba CLI installation
# These functions provide logging, OS detection, dependency management, and installation verification

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#######################################
# Log informational message
# Arguments:
#   $1 - Message to log
# Outputs:
#   Writes message to stdout in blue and sends to syslog
#######################################
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} ${message}"
    logger -t "$(basename $0)" -p user.info "[INFO] ${message}"
}

#######################################
# Log warning message
# Arguments:
#   $1 - Warning message to log
# Outputs:
#   Writes warning to stdout in yellow and sends to syslog
#######################################
log_warn() {
    local message="$1"
    echo -e "${YELLOW}[WARN]${NC} ${message}"
    logger -t "$(basename $0)" -p user.warning "[WARN] ${message}"
}

#######################################
# Log error message
# Arguments:
#   $1 - Error message to log
# Outputs:
#   Sends error to syslog only
#######################################
log_error() {
    local message="$1"
    logger -t "$(basename $0)" -p user.error "[ERROR] ${message}"
}

#######################################
# Check if a command/package is installed
# Arguments:
#   $1 - Command name to check
# Returns:
#   0 if installed, 1 if not installed
#######################################
check_installed() {
    local command_name="$1"
    if command -v "${command_name}" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

#######################################
# Detect operating system
# Arguments:
#   None
# Outputs:
#   Prints OS type (ubuntu, debian, centos, rhel, fedora, macos, unknown)
# Returns:
#   0 on success, 1 on unknown OS
#######################################
check_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
        return 0
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu)
                echo "ubuntu"
                return 0
                ;;
            debian)
                echo "debian"
                return 0
                ;;
            centos)
                echo "centos"
                return 0
                ;;
            rhel)
                echo "rhel"
                return 0
                ;;
            fedora)
                echo "fedora"
                return 0
                ;;
            *)
                echo "unknown"
                return 1
                ;;
        esac
    else
        echo "unknown"
        return 1
    fi
}

#######################################
# Install dependencies based on OS
# Arguments:
#   $1 - Operating system type (from check_os)
#   $@ - List of package names to install
# Returns:
#   0 on success, 1 on failure
#######################################
install_deps() {
    local os_type="$1"
    shift
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_error "No packages specified for installation"
        return 1
    fi
    
    log_info "Installing dependencies: ${packages[*]}"
    
    case "$os_type" in
        ubuntu|debian)
            sudo apt-get update -qq || return 1
            sudo apt-get install -y "${packages[@]}" || return 1
            ;;
        centos|rhel|fedora)
            sudo yum install -y "${packages[@]}" || return 1
            ;;
        macos)
            if ! check_installed brew; then
                log_error "Homebrew is required but not installed. Please install from https://brew.sh"
                return 1
            fi
            brew install "${packages[@]}" || return 1
            ;;
        *)
            log_error "Unsupported operating system: $os_type"
            return 1
            ;;
    esac
    
    return 0
}

#######################################
# Verify installation of a command
# Arguments:
#   $1 - Command name to verify
#   $2 - (Optional) Expected version pattern (regex)
# Outputs:
#   Success or failure message
# Returns:
#   0 if verified successfully, 1 on failure
#######################################
verify_installation() {
    local command_name="$1"
    local version_pattern="${2:-}"
    
    if ! check_installed "${command_name}"; then
        log_error "${command_name} is not installed or not in PATH"
        return 1
    fi
    
    log_info "${command_name} is installed successfully"
    
    # Try to get version information
    local version_output=""
    if version_output=$("${command_name}" --version 2>&1); then
        log_info "${command_name} version: ${version_output}"
        
        # If version pattern provided, validate it
        if [[ -n "${version_pattern}" ]]; then
            if echo "${version_output}" | grep -qE "${version_pattern}"; then
                log_info "Version matches expected pattern: ${version_pattern}"
                return 0
            else
                log_warn "Version does not match expected pattern: ${version_pattern}"
                return 1
            fi
        fi
    else
        log_info "${command_name} is available (version info not accessible)"
    fi
    
    return 0
}
