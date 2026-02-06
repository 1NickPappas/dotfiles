#!/bin/bash
# Main bootstrap script - runs all setup scripts in order
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pre-flight checks
echo "Running pre-flight checks..."

if [[ $EUID -eq 0 ]]; then
    echo "ERROR: Don't run as root. Run as your normal user."
    exit 1
fi

if ! ping -c 1 -W 3 archlinux.org &>/dev/null; then
    echo "ERROR: No network connection."
    exit 1
fi

if ! sudo -v; then
    echo "ERROR: sudo access required."
    exit 1
fi

echo "Pre-flight checks passed!"
echo ""

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

# Check critical commands available
echo "=== Quick Command Check ==="
for cmd in chezmoi zsh Hyprland; do
    if command -v "$cmd" &>/dev/null; then
        echo "✓ $cmd installed"
    else
        echo "✗ $cmd NOT FOUND"
    fi
done

# Run comprehensive dotfiles verification
"$SCRIPT_DIR/verify-dotfiles.sh"

echo ""
echo "=== Bootstrap complete! ==="
echo "Reboot to start Hyprland automatically."
