#!/bin/bash
# Set zsh as default shell (works on Linux and macOS)
set -euo pipefail

echo "=== Setting zsh as default shell ==="

# Check current shell
if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    echo "zsh is already the default shell"
    exit 0
fi

# Detect OS and set zsh path
if [[ "$OSTYPE" == "darwin"* ]]; then
    ZSH_PATH="/bin/zsh"
else
    ZSH_PATH="/usr/bin/zsh"
    # Install zsh if not present (Linux only)
    if ! command -v zsh &>/dev/null; then
        echo "Installing zsh..."
        sudo pacman -S --needed --noconfirm zsh
    fi
fi

echo "Changing default shell to zsh..."
chsh -s "$ZSH_PATH"

echo "Done! Logout and login again for changes to take effect."
