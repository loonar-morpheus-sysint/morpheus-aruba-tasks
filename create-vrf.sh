#!/bin/bash

################################################################################
# Script: create-vrf.sh
# Description: Create a new VRF in Aruba switch
# Usage:
#   ./create-vrf.sh --vrf-name <name> --vrf-description <desc> --vrf-vlan <vlan>
#   ./create-vrf.sh (interactive mode)
#
# Examples:
#   ./create-vrf.sh --vrf-name CUSTOMER_A --vrf-description "Customer A Network" --vrf-vlan 100
#   ./create-vrf.sh --vrf-name MGMT_VRF --vrf-description "Management VRF" --vrf-vlan 10 --route-distinguisher 65000:10
#   ./create-vrf.sh (will prompt for all parameters)
#
# Parameters:
#   --vrf-name           : VRF name (required)
#   --vrf-description    : VRF description (required)
#   --vrf-vlan          : VLAN ID for VRF (required)
#   --route-distinguisher: Route distinguisher (optional, format: ASN:nn)
#   --help              : Show this help message
################################################################################

# Stop execution on any error
set -e

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source common functions and authentication
source "${SCRIPT_DIR}/commons.sh"
source "${SCRIPT_DIR}/aruba_auth.sh"

################################################################################
# Functions
################################################################################

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Create a new VRF in Aruba switch

Options:
  --vrf-name NAME              VRF name (required)
  --vrf-description DESC       VRF description (required)
  --vrf-vlan VLAN             VLAN ID for VRF (required)
  --route-distinguisher RD     Route distinguisher (optional, format: ASN:nn)
  --help                       Show this help message

Examples:
  $0 --vrf-name CUSTOMER_A --vrf-description "Customer A Network" --vrf-vlan 100
  $0 --vrf-name MGMT_VRF --vrf-description "Management VRF" --vrf-vlan 10 --route-distinguisher 65000:10
  $0  # Interactive mode

EOF
    exit 0
}

# Validate VRF name
validate_vrf_name() {
    local vrf_name="$1"
    
    if [[ -z "${vrf_name}" ]]; then
        log_error "VRF name cannot be empty"
        return 1
    fi
    
    # Check if VRF name contains only alphanumeric, underscore, and hyphen
    if ! [[ "${vrf_name}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "VRF name must contain only alphanumeric characters, underscores, and hyphens"
        return 1
    fi
    
    # Check length (typical limit is 32 characters)
    if [[ ${#vrf_name} -gt 32 ]]; then
        log_error "VRF name must be 32 characters or less"
        return 1
    fi
    
    log_info "VRF name validation passed: ${vrf_name}"
    return 0
}

# Validate VLAN ID
validate_vlan() {
    local vlan="$1"
    
    if [[ -z "${vlan}" ]]; then
        log_error "VLAN ID cannot be empty"
        return 1
    fi
    
    # Check if VLAN is a number
    if ! [[ "${vlan}" =~ ^[0-9]+$ ]]; then
        log_error "VLAN ID must be a number"
        return 1
    fi
    
    # Check VLAN range (1-4094)
    if [[ ${vlan} -lt 1 || ${vlan} -gt 4094 ]]; then
        log_error "VLAN ID must be between 1 and 4094"
        return 1
    fi
    
    log_info "VLAN ID validation passed: ${vlan}"
    return 0
}

# Validate route distinguisher format
validate_route_distinguisher() {
    local rd="$1"
    
    # If empty, it's optional so return success
    if [[ -z "${rd}" ]]; then
        return 0
    fi
    
    # Check format ASN:nn or IP:nn
    if ! [[ "${rd}" =~ ^[0-9]+:[0-9]+$ ]]; then
        log_error "Route distinguisher must be in format ASN:nn (e.g., 65000:10)"
        return 1
    fi
    
    log_info "Route distinguisher validation passed: ${rd}"
    return 0
}

# Prompt for VRF parameters
prompt_vrf_parameters() {
    log_info "Entering interactive mode - please provide VRF details"
    
    # Prompt for VRF name
    while true; do
        read -p "Enter VRF name: " VRF_NAME
        if validate_vrf_name "${VRF_NAME}"; then
            break
        fi
    done
    
    # Prompt for VRF description
    read -p "Enter VRF description: " VRF_DESCRIPTION
    if [[ -z "${VRF_DESCRIPTION}" ]]; then
        log_error "VRF description cannot be empty"
        exit 1
    fi
    
    # Prompt for VLAN ID
    while true; do
        read -p "Enter VLAN ID: " VRF_VLAN
        if validate_vlan "${VRF_VLAN}"; then
            break
        fi
    done
    
    # Prompt for optional route distinguisher
    read -p "Enter route distinguisher (optional, press Enter to skip): " ROUTE_DISTINGUISHER
    if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
        if ! validate_route_distinguisher "${ROUTE_DISTINGUISHER}"; then
            exit 1
        fi
    fi
}

# Create VRF in Aruba
create_vrf() {
    log_info "Starting VRF creation process"
    log_info "VRF Name: ${VRF_NAME}"
    log_info "VRF Description: ${VRF_DESCRIPTION}"
    log_info "VRF VLAN: ${VRF_VLAN}"
    
    if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
        log_info "Route Distinguisher: ${ROUTE_DISTINGUISHER}"
    fi
    
    # Authenticate with Aruba CLI
    log_info "Authenticating with Aruba CLI"
    if ! aruba_auth; then
        log_error "Failed to authenticate with Aruba CLI"
        exit 1
    fi
    
    log_info "Authentication successful"
    
    # Create VRF using Aruba CLI
    log_info "Creating VRF ${VRF_NAME}..."
    
    # Build the command
    local cmd="aoscx vrf create ${VRF_NAME}"
    
    # Execute VRF creation
    if ! ${cmd}; then
        log_error "Failed to create VRF ${VRF_NAME}"
        exit 1
    fi
    
    log_info "VRF ${VRF_NAME} created successfully"
    
    # Configure VRF description
    log_info "Configuring VRF description..."
    if ! aoscx vrf ${VRF_NAME} description "${VRF_DESCRIPTION}"; then
        log_error "Failed to set VRF description"
        exit 1
    fi
    
    log_info "VRF description configured"
    
    # Configure VLAN association if needed
    log_info "Associating VLAN ${VRF_VLAN} with VRF ${VRF_NAME}..."
    if ! aoscx vlan ${VRF_VLAN} vrf ${VRF_NAME}; then
        log_error "Failed to associate VLAN with VRF"
        exit 1
    fi
    
    log_info "VLAN ${VRF_VLAN} associated with VRF ${VRF_NAME}"
    
    # Configure route distinguisher if provided
    if [[ -n "${ROUTE_DISTINGUISHER}" ]]; then
        log_info "Configuring route distinguisher..."
        if ! aoscx vrf ${VRF_NAME} route-distinguisher ${ROUTE_DISTINGUISHER}; then
            log_error "Failed to configure route distinguisher"
            exit 1
        fi
        log_info "Route distinguisher configured"
    fi
    
    # Save configuration
    log_info "Saving configuration..."
    if ! aoscx write memory; then
        log_warning "Failed to save configuration - changes may be lost on reboot"
    else
        log_info "Configuration saved successfully"
    fi
    
    log_info "VRF ${VRF_NAME} creation completed successfully!"
}

################################################################################
# Main Script
################################################################################

log_info "========================================"
log_info "VRF Creation Script Started"
log_info "========================================"

# Parse command line arguments
VRF_NAME=""
VRF_DESCRIPTION=""
VRF_VLAN=""
ROUTE_DISTINGUISHER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --vrf-name)
            VRF_NAME="$2"
            shift 2
            ;;
        --vrf-description)
            VRF_DESCRIPTION="$2"
            shift 2
            ;;
        --vrf-vlan)
            VRF_VLAN="$2"
            shift 2
            ;;
        --route-distinguisher)
            ROUTE_DISTINGUISHER="$2"
            shift 2
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            log_error "Unknown parameter: $1"
            show_usage
            ;;
    esac
done

# Check if parameters were provided via command line
if [[ -z "${VRF_NAME}" || -z "${VRF_DESCRIPTION}" || -z "${VRF_VLAN}" ]]; then
    log_info "Missing required parameters, switching to interactive mode"
    prompt_vrf_parameters
else
    log_info "Parameters provided via command line"
    
    # Validate all provided parameters
    log_info "Validating parameters..."
    
    if ! validate_vrf_name "${VRF_NAME}"; then
        exit 1
    fi
    
    if [[ -z "${VRF_DESCRIPTION}" ]]; then
        log_error "VRF description cannot be empty"
        exit 1
    fi
    
    if ! validate_vlan "${VRF_VLAN}"; then
        exit 1
    fi
    
    if ! validate_route_distinguisher "${ROUTE_DISTINGUISHER}"; then
        exit 1
    fi
    
    log_info "All parameters validated successfully"
fi

# Create the VRF
create_vrf

log_info "========================================"
log_info "VRF Creation Script Completed"
log_info "========================================"

exit 0
