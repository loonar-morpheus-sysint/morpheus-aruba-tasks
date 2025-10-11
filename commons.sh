#!/bin/bash
# commons.sh - Reusable functions for Aruba CLI installation
# These functions provide logging, OS detection, dependency management, and installation verification

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load environment variables from .env file if it exists
if [[ -f ".env" ]]; then
    # shellcheck disable=SC1091  # .env file is optional and not tracked
    source .env
fi

# Parse LOG_VIEW from .env and store in array
# Format: "debug, info, notice, warn, err, crit, alert, emerg"
if [[ -n "${LOG_VIEW}" ]]; then
    IFS=',' read -ra LOG_VIEW_ARRAY <<< "${LOG_VIEW}"
    # Trim whitespace from each element
    for i in "${!LOG_VIEW_ARRAY[@]}"; do
        # shellcheck disable=SC2004  # Array index doesn't need arithmetic expansion
        LOG_VIEW_ARRAY[${i}]=$(echo "${LOG_VIEW_ARRAY[${i}]}" | xargs)
    done
else
    # Default: show all levels
    LOG_VIEW_ARRAY=("debug" "info" "notice" "warn" "err" "crit" "alert" "emerg")
fi

#######################################
# Check if a log level should be displayed
# Arguments:
#   $1 - Log level to check
# Returns:
#   0 if should display, 1 if not
#######################################
should_display_log() {
    local level="$1"
    for view_level in "${LOG_VIEW_ARRAY[@]}"; do
        if [[ "${view_level}" == "${level}" ]]; then
            return 0
        fi
    done
    return 1
}

#######################################
# Generic log function
# Arguments:
#   $1 - Syslog severity level (debug, info, notice, warn, err, crit, alert, emerg)
#   $2 - Display label (e.g., DEBUG, INFO, WARN, ERROR)
#   $3 - Color code for display
#   $4 - Message to log
# Outputs:
#   Writes message to stdout (if enabled in LOG_VIEW) and sends to syslog
#######################################
log_message() {
    local syslog_level="$1"
    local label="$2"
    local color="$3"
    local message="$4"

    # Always send to syslog
    logger -t "$(basename "$0")" -p "user.${syslog_level}" "[${label}] ${message}"

    # Display on screen only if level is in LOG_VIEW
    if should_display_log "${syslog_level}"; then
        echo -e "${color}[${label}]${NC} ${message}"
    fi
}

#######################################
# Log debug message
# Arguments:
#   $1 - Message to log
# Outputs:
#   Writes message to stdout (if enabled) and sends to syslog with debug priority
#######################################
log_debug() {
    log_message "debug" "DEBUG" "${NC}" "$1"
}

#######################################
# Log informational message
# Arguments:
#   $1 - Message to log
# Outputs:
#   Writes message to stdout (if enabled) and sends to syslog with info priority
#######################################
log_info() {
    log_message "info" "INFO" "${BLUE}" "$1"
}

#######################################
# Log notice message
# Arguments:
#   $1 - Message to log
# Outputs:
#   Writes message to stdout (if enabled) and sends to syslog with notice priority
#######################################
log_notice() {
    log_message "notice" "NOTICE" "${GREEN}" "$1"
}

#######################################
# Log warning message
# Arguments:
#   $1 - Warning message to log
# Outputs:
#   Writes warning to stdout (if enabled) and sends to syslog with warning priority
#######################################
log_warn() {
    log_message "warn" "WARN" "${YELLOW}" "$1"
}

#######################################
# Log error message
# Arguments:
#   $1 - Error message to log
# Outputs:
#   Writes error to stdout (if enabled) and sends to syslog with err priority
#######################################
log_error() {
    log_message "err" "ERROR" "${RED}" "$1"
}

#######################################
# Log critical message
# Arguments:
#   $1 - Critical message to log
# Outputs:
#   Writes critical message to stdout (if enabled) and sends to syslog with crit priority
#######################################
log_crit() {
    log_message "crit" "CRITICAL" "${RED}" "$1"
}

#######################################
# Log alert message
# Arguments:
#   $1 - Alert message to log
# Outputs:
#   Writes alert to stdout (if enabled) and sends to syslog with alert priority
#######################################
log_alert() {
    log_message "alert" "ALERT" "${RED}" "$1"
}

#######################################
# Log emergency message
# Arguments:
#   $1 - Emergency message to log
# Outputs:
#   Writes emergency to stdout (if enabled) and sends to syslog with emerg priority
#######################################
log_emerg() {
    log_message "emerg" "EMERGENCY" "${RED}" "$1"
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
    if [[ "${OSTYPE}" == "darwin"* ]]; then
        echo "macos"
        return 0
    elif [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        # shellcheck disable=SC2154  # ID is defined in /etc/os-release
        case "${ID}" in
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

    case "${os_type}" in
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
            log_error "Unsupported operating system: ${os_type}"
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
