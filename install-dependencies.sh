#!/bin/bash

# GLADIS Qt6 Dependencies Installation Script
# This script installs all required Qt6 packages for the GameLab application
# Run this on the Raspberry Pi deployment target

set -e  # Exit on error

echo "================================"
echo "GLADIS Dependencies Installer"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please run this script as a normal user (not root)"
    echo "The script will use sudo when needed"
    exit 1
fi

echo "Updating package lists..."
sudo apt update

echo ""
echo "Installing Qt6 base packages..."
sudo apt install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    qml6-module-qtquick \
    qml6-module-qtquick-controls \
    qml6-module-qtquick-layouts \
    qml6-module-qtquick-window

echo ""
echo "Installing Qt6 Quick Controls and Templates..."
sudo apt install -y \
    qml6-module-qtquick-templates \
    libqt6quickcontrols2-6

echo ""
echo "Installing Qt6 multimedia and additional modules..."
sudo apt install -y \
    qt6-multimedia-dev \
    libqt6core6 \
    libqt6gui6 \
    libqt6qml6 \
    libqt6quick6

echo ""
echo "Installing build tools..."
sudo apt install -y \
    cmake \
    build-essential \
    pkg-config

echo ""
echo "Installing optional but useful Qt6 tools..."
sudo apt install -y \
    qt6-tools-dev \
    qt6-tools-dev-tools

echo ""
echo "================================"
echo "Installation Complete!"
echo "================================"
echo ""
echo "Installed packages:"
echo "  - Qt6 Base Development"
echo "  - Qt6 Declarative (QML)"
echo "  - Qt6 Quick Controls & Templates"
echo "  - Qt6 Multimedia"
echo "  - Build tools (CMake, GCC)"
echo ""
echo "You can now build and run the GLADIS application."
echo ""
echo "To build the application:"
echo "  cd ~/self_contained_app_layers_v2"
echo "  mkdir -p build-rpi"
echo "  cd build-rpi"
echo "  cmake .."
echo "  make -j4"
echo ""
