#!/bin/bash
# Install packages from package lists
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

echo "=== Installing packages ==="

# Function to read package list (strips comments and empty lines)
read_packages() {
    grep -v '^#' "$1" | grep -v '^$' | tr '\n' ' '
}

# Install from official repos
echo "Installing packages from official repos..."
OFFICIAL_PACKAGES=$(read_packages "$PACKAGES_DIR/base.txt")
OFFICIAL_PACKAGES+=" $(read_packages "$PACKAGES_DIR/desktop.txt")"

if [ -n "$OFFICIAL_PACKAGES" ]; then
    sudo pacman -S --needed --noconfirm $OFFICIAL_PACKAGES
fi

# Install AUR packages
echo "Installing AUR packages..."
AUR_PACKAGES=$(read_packages "$PACKAGES_DIR/aur.txt")

if [ -n "$AUR_PACKAGES" ]; then
    yay -S --needed --noconfirm $AUR_PACKAGES
fi

# Post-install: Add user to docker group if docker is installed
if command -v docker &> /dev/null; then
    if ! groups "$USER" | grep -q docker; then
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        echo "NOTE: Log out and back in for docker group to take effect"
    fi
fi

echo "All packages installed successfully!"
