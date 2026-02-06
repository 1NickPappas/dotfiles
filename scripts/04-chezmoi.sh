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

# Verify critical files were applied
echo ""
echo "Verifying critical dotfiles..."
VERIFY_FAILED=0
VERIFY_FILES=(
    "$HOME/.config/hypr/hyprland.conf"
    "$HOME/.local/bin/start-hyprland"
    "$HOME/.zshrc"
)
for f in "${VERIFY_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "  ✓ $f"
    else
        echo "  ✗ $f MISSING"
        VERIFY_FAILED=1
    fi
done

if [[ $VERIFY_FAILED -eq 1 ]]; then
    read -p "Some dotfiles are missing. Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

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
