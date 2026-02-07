#!/bin/bash
# Initialize chezmoi and apply dotfiles
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/../dotfiles"

echo "=== Setting up dotfiles with chezmoi ==="

# =============================================
# PRE-FLIGHT VALIDATION
# =============================================

# 1. Verify chezmoi is installed
if ! command -v chezmoi &>/dev/null; then
    echo "ERROR: chezmoi is not installed."
    echo "This should have been installed by 03-packages.sh"
    echo "Try: sudo pacman -S chezmoi"
    exit 1
fi
echo "  OK chezmoi is installed"

# 2. Verify DOTFILES_DIR exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "ERROR: Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi
echo "  OK Dotfiles directory exists"

# 3. Verify critical source files
REQUIRED_FILES=(
    ".chezmoi.toml.tmpl"
    ".chezmoidata/themes.toml"
    "dot_zshrc.tmpl"
)
for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$DOTFILES_DIR/$file" ]]; then
        echo "ERROR: Required file missing: $DOTFILES_DIR/$file"
        exit 1
    fi
done
echo "  OK All required source files present"

# Ensure chezmoi data directory exists
mkdir -p ~/.local/share/chezmoi

# Initialize chezmoi from local dotfiles directory
echo "Initializing chezmoi..."
chezmoi init --source="$DOTFILES_DIR" --force

# Validate templates with dry run
echo "Validating templates..."
if ! chezmoi apply --dry-run 2>&1; then
    echo "ERROR: Template validation failed"
    echo "Check for missing theme data or template syntax errors"
    exit 1
fi

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
    sudo chsh -s /usr/bin/zsh "$USER"
    echo "Shell changed to zsh (will take effect on next login)"
fi
