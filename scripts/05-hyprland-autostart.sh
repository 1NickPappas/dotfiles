#!/bin/bash
# Configure Hyprland to auto-start on tty1 login
# Only starts on tty1 to allow other TTYs for recovery
set -euo pipefail

echo "=== Configuring Hyprland auto-start ==="

# Verify start-hyprland script exists (installed via chezmoi)
if [[ ! -x "$HOME/.local/bin/start-hyprland" ]]; then
    echo "WARNING: start-hyprland not found at ~/.local/bin/start-hyprland"
    echo "Make sure chezmoi has been applied first (chezmoi apply)"
    echo "Continuing anyway - it will be available after chezmoi apply"
fi

ZPROFILE="$HOME/.zprofile"

# Create .zprofile if it doesn't exist
touch "$ZPROFILE"

# Add auto-start if not already present
if ! grep -q "Auto-start Hyprland" "$ZPROFILE"; then
    cat >> "$ZPROFILE" << 'EOF'

# Auto-start Hyprland on tty1
if [[ $(tty) = /dev/tty1 ]] && ! pgrep -x Hyprland > /dev/null; then
    exec start-hyprland
fi
EOF
    echo "Hyprland auto-start configured in $ZPROFILE"
else
    echo "Hyprland auto-start already configured in $ZPROFILE"
fi
