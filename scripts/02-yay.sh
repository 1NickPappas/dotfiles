#!/bin/bash
# Install yay AUR helper
set -euo pipefail

echo "=== Installing yay AUR helper ==="

if command -v yay &>/dev/null; then
    echo "yay is already installed"
    yay --version
    exit 0
fi

# Ensure base-devel and git are installed
sudo pacman -S --needed --noconfirm base-devel git

# Clean up any existing /tmp/yay from failed runs
rm -rf /tmp/yay 2>/dev/null || true

# Clone and build yay
echo "Cloning yay from AUR..."
git clone https://aur.archlinux.org/yay.git /tmp/yay

echo "Building and installing yay..."
cd /tmp/yay
makepkg -si --noconfirm

# Cleanup
rm -rf /tmp/yay

echo "yay installed successfully!"
yay --version
