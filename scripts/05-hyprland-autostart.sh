#!/bin/bash
# Configure Hyprland to auto-start on tty1 login
# Only starts on tty1 to allow other TTYs for recovery
set -euo pipefail

echo "=== Configuring Hyprland auto-start ==="

# Verify official start-hyprland exists
if [[ ! -x "/usr/bin/start-hyprland" ]]; then
    echo "WARNING: /usr/bin/start-hyprland not found"
    echo "This is provided by the Hyprland package"
    echo "Try: sudo pacman -S hyprland"
fi

ZPROFILE="$HOME/.zprofile"

# Create .zprofile if it doesn't exist
touch "$ZPROFILE"

# Add auto-start if not already present
if ! grep -q "Auto-start Hyprland" "$ZPROFILE"; then
    cat >> "$ZPROFILE" << 'EOF'

# Auto-start Hyprland on tty1
if [[ $(tty) = /dev/tty1 ]] && ! pgrep -x Hyprland > /dev/null; then
    exec /usr/bin/start-hyprland
fi
EOF
    echo "Hyprland auto-start configured in $ZPROFILE"
else
    echo "Hyprland auto-start already configured in $ZPROFILE"
fi
