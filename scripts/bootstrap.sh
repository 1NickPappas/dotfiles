#!/bin/bash
# Main bootstrap script - runs all setup scripts in order
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Arch Linux Post-Install Bootstrap ==="
echo ""

# Run scripts in order
"$SCRIPT_DIR/01-snapshot.sh"
"$SCRIPT_DIR/02-yay.sh"
"$SCRIPT_DIR/03-packages.sh"
"$SCRIPT_DIR/04-chezmoi.sh"

echo ""
echo "=== Bootstrap complete! ==="
echo "You can now start Hyprland with: Hyprland"
