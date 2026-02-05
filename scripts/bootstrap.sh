#!/bin/bash
# Main bootstrap script - runs all setup scripts in order
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Security: Remove archinstall credential logs if they exist
CREDS_LOG="/var/log/archinstall/user_credentials.json"
if [[ -f "$CREDS_LOG" ]]; then
    echo "Removing archinstall credential logs..."
    sudo shred -u "$CREDS_LOG"
fi

echo "=== Arch Linux Post-Install Bootstrap ==="
echo ""

# Ask about snapshot (skip if running after rollback)
read -p "Create btrfs snapshot before changes? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/01-snapshot.sh"
fi

# Run setup scripts in order
"$SCRIPT_DIR/02-yay.sh"
"$SCRIPT_DIR/03-packages.sh"
"$SCRIPT_DIR/04-chezmoi.sh"
"$SCRIPT_DIR/05-hyprland-autostart.sh"

echo ""
echo "=== Bootstrap complete! ==="
echo "Reboot to start Hyprland automatically."
