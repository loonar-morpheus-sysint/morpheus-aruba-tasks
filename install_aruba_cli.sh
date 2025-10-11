#!/bin/bash
# Script to detect and install Aruba CLI (aoscx) on Ubuntu
# Usage: ./install_aruba_cli.sh

set -e

# Source common functions
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SOURCE_DIR}/commons.sh"

# Main script
main() {
    log_info "Checking for Aruba CLI installation..."
    
    # Check if aoscx CLI is already installed
    if check_installed "aoscx"; then
        log_info "Aruba CLI (aoscx) is already installed."
        aoscx --version
        exit 0
    fi
    
    log_info "Aruba CLI not found. Installing..."
    
    # Check if running on Ubuntu
    check_os
    
    # Install dependencies (python3 and pip3)
    install_deps
    
    # Install Aruba CLI using pip
    log_info "Installing Aruba aoscx CLI via pip..."
    sudo pip3 install pyaoscx
    
    # Verify installation
    verify_installation "aoscx"
    
    log_info "Installation complete!"
}

main "$@"
