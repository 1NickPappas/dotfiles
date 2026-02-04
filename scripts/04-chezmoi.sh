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

# Initialize chezmoi from local dotfiles directory
echo "Initializing chezmoi..."
chezmoi init --source="$DOTFILES_DIR"

# Apply dotfiles
echo "Applying dotfiles..."
chezmoi apply -v

echo "Dotfiles applied successfully!"
echo "Applied configs:"
chezmoi managed
