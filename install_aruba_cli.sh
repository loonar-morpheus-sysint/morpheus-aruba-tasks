#!/bin/bash

# Script to detect and install Aruba CLI (aoscx) on Ubuntu
# Usage: ./install_aruba_cli.sh

set -e

echo "Checking for Aruba CLI installation..."

# Check if aoscx CLI is installed
if command -v aoscx &> /dev/null; then
    echo "Aruba CLI (aoscx) is already installed."
    aoscx --version
    exit 0
fi

echo "Aruba CLI not found. Installing..."

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    echo "Warning: This script is designed for Ubuntu. Your system may not be compatible."
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Python3 and pip if not installed
if ! command -v python3 &> /dev/null; then
    echo "Installing Python3..."
    sudo apt-get install -y python3
fi

if ! command -v pip3 &> /dev/null; then
    echo "Installing pip3..."
    sudo apt-get install -y python3-pip
fi

# Install Aruba CLI using pip
echo "Installing Aruba aoscx CLI via pip..."
sudo pip3 install pyaoscx

# Verify installation
if command -v aoscx &> /dev/null; then
    echo "Aruba CLI installed successfully!"
    aoscx --version
else
    echo "Installation completed, but aoscx command not found in PATH."
    echo "You may need to add ~/.local/bin to your PATH or restart your terminal."
    echo "Add this line to your ~/.bashrc: export PATH=\"$HOME/.local/bin:\$PATH\""
fi

echo "Installation complete!"
