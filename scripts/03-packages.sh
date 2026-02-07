#!/bin/bash
# Install packages from package lists
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

echo "=== Installing packages ==="

# Function to read package list (strips comments and empty lines)
read_packages() {
    grep -v '^#' "$1" | grep -v '^$' | tr '\n' ' '
}

# Install from official repos
echo "Installing packages from official repos..."
OFFICIAL_PACKAGES=$(read_packages "$PACKAGES_DIR/base.txt")
OFFICIAL_PACKAGES+=" $(read_packages "$PACKAGES_DIR/desktop.txt")"

if [ -n "$OFFICIAL_PACKAGES" ]; then
    sudo pacman -S --needed --noconfirm $OFFICIAL_PACKAGES
fi

# Pre-install: Remove conflicting packages
# rustup conflicts with system rust package (only if rustup not already installed)
if ! command -v rustup &> /dev/null && pacman -Q rust &> /dev/null && grep -q "rustup" "$PACKAGES_DIR/aur.txt"; then
    echo "Removing system rust package (conflicts with rustup)..."
    sudo pacman -Rns --noconfirm rust
fi

# Install AUR packages (individually to allow partial failures)
echo "Installing AUR packages..."
AUR_PACKAGES=$(read_packages "$PACKAGES_DIR/aur.txt")

if [ -n "$AUR_PACKAGES" ]; then
    for pkg in $AUR_PACKAGES; do
        yay -S --needed --noconfirm --pgpfetch "$pkg" || echo "WARNING: Failed to install AUR package: $pkg"
    done
fi

# Post-install: Add user to docker group if docker is installed
if command -v docker &> /dev/null; then
    if ! groups "$USER" | grep -q docker; then
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        echo "NOTE: Log out and back in for docker group to take effect"
    fi
fi

# Post-install: Initialize language toolchains
if command -v rustup &> /dev/null; then
    if ! rustup show active-toolchain &> /dev/null; then
        echo "Initializing Rust toolchain..."
        rustup default stable
        rustup component add rust-analyzer clippy rustfmt rust-src
    fi
fi

if command -v fnm &> /dev/null; then
    echo "Installing Node.js LTS via fnm..."
    eval "$(fnm env --shell bash)"
    fnm install --lts
    # Re-source fnm env to get the newly installed node in PATH
    eval "$(fnm env --shell bash)"
    corepack enable
fi

# Install global packages from package managers
echo "Installing global packages..."

if command -v npm &> /dev/null && [ -f "$PACKAGES_DIR/npm-global.txt" ]; then
    NPM_PACKAGES=$(read_packages "$PACKAGES_DIR/npm-global.txt")
    if [ -n "$NPM_PACKAGES" ]; then
        echo "Installing global npm packages..."
        npm install -g $NPM_PACKAGES || echo "WARNING: Some npm packages failed to install"
    fi
fi

if command -v pnpm &> /dev/null && [ -f "$PACKAGES_DIR/pnpm-global.txt" ]; then
    PNPM_PACKAGES=$(read_packages "$PACKAGES_DIR/pnpm-global.txt")
    if [ -n "$PNPM_PACKAGES" ]; then
        echo "Installing global pnpm packages..."
        pnpm add -g $PNPM_PACKAGES || echo "WARNING: Some pnpm packages failed to install"
    fi
fi

if command -v bun &> /dev/null && [ -f "$PACKAGES_DIR/bun-global.txt" ]; then
    BUN_PACKAGES=$(read_packages "$PACKAGES_DIR/bun-global.txt")
    if [ -n "$BUN_PACKAGES" ]; then
        echo "Installing global bun packages..."
        bun add -g $BUN_PACKAGES || echo "WARNING: Some bun packages failed to install"
    fi
fi

if command -v cargo &> /dev/null && [ -f "$PACKAGES_DIR/cargo-global.txt" ]; then
    CARGO_PACKAGES=$(read_packages "$PACKAGES_DIR/cargo-global.txt")
    if [ -n "$CARGO_PACKAGES" ]; then
        echo "Installing cargo packages..."
        for pkg in $CARGO_PACKAGES; do
            cargo install "$pkg" || echo "WARNING: Failed to install cargo package: $pkg"
        done
    fi
fi

if command -v go &> /dev/null && [ -f "$PACKAGES_DIR/go-global.txt" ]; then
    GO_PACKAGES=$(read_packages "$PACKAGES_DIR/go-global.txt")
    if [ -n "$GO_PACKAGES" ]; then
        echo "Installing go packages..."
        for pkg in $GO_PACKAGES; do
            go install "$pkg" || echo "WARNING: Failed to install go package: $pkg"
        done
    fi
fi

echo "All packages installed successfully!"
