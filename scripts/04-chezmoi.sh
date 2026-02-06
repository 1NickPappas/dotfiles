#!/bin/bash
# Initialize chezmoi and apply dotfiles
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"

echo "=== Setting up dotfiles with chezmoi ==="

# Install chezmoi if not present
if ! command -v chezmoi &>/dev/null; then
    echo "Installing chezmoi..."
    sudo pacman -S --needed --noconfirm chezmoi
fi

# Ensure chezmoi data directory exists
mkdir -p ~/.local/share/chezmoi

# Initialize chezmoi from local dotfiles directory
echo "Initializing chezmoi..."
chezmoi init --source="$DOTFILES_DIR"

# Apply dotfiles
echo "Applying dotfiles..."
chezmoi apply -v

echo "Dotfiles applied successfully!"
echo "Applied configs:"
chezmoi managed

# Enable Walker's elephant service (if installed)
if command -v elephant &>/dev/null; then
    echo "Enabling elephant service for Walker..."
    elephant service enable
fi

# Set zsh as default shell (required for .zprofile to work)
if [ "$SHELL" != "/usr/bin/zsh" ] && command -v zsh &>/dev/null; then
    echo ""
    echo "Setting zsh as default shell..."
    echo "You may be prompted for your password."
    chsh -s /usr/bin/zsh
    echo "Shell changed to zsh (will take effect on next login)"
fi
