#!/bin/bash
# Verify chezmoi dotfiles setup is correct and complete
set -euo pipefail

echo "=== Dotfiles Verification ==="
echo ""

ERRORS=0
WARNINGS=0

# Helper functions
pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; ((ERRORS++)) || true; }
warn() { echo "  ⚠ $1"; ((WARNINGS++)) || true; }

# Expand ~ for file checks
HOME_DIR="$HOME"

# =======================
# 1. Critical Files Exist
# =======================
echo "Checking critical files..."

CRITICAL_FILES=(
    "$HOME_DIR/.config/hypr/hyprland.conf"
    "$HOME_DIR/.config/hypr/monitors.conf"
    "$HOME_DIR/.config/hypr/input.conf"
    "$HOME_DIR/.config/hypr/appearance.conf"
    "$HOME_DIR/.config/hypr/bindings.conf"
    "$HOME_DIR/.config/hypr/autostart.conf"
    "$HOME_DIR/.config/hypr/rules.conf"
    "$HOME_DIR/.zshrc"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        pass "$file exists"
    else
        fail "$file MISSING"
    fi
done

echo ""

# =======================
# 2. Executable Permissions
# =======================
echo "Checking executable permissions..."

EXECUTABLE_SCRIPTS=(
    "screenshot"
    "screenrecord"
    "volume-control"
    "brightness-control"
    "theme-set"
)

for script in "${EXECUTABLE_SCRIPTS[@]}"; do
    script_path="$HOME_DIR/.local/bin/$script"
    if [[ -f "$script_path" ]]; then
        if [[ -x "$script_path" ]]; then
            pass "$script is executable"
        else
            fail "$script exists but is NOT executable"
        fi
    else
        warn "$script not found in ~/.local/bin/"
    fi
done

echo ""

# =======================
# 3. Critical Content Checks
# =======================
echo "Checking file contents..."

# Check ~/.zshrc
if [[ -f "$HOME_DIR/.zshrc" ]]; then
    if grep -q 'PATH.*\.local/bin' "$HOME_DIR/.zshrc" 2>/dev/null || \
       grep -q 'path.*\.local/bin' "$HOME_DIR/.zshrc" 2>/dev/null; then
        pass "~/.zshrc includes ~/.local/bin in PATH"
    else
        fail "~/.zshrc does not include ~/.local/bin in PATH"
    fi

    if grep -q 'EDITOR=' "$HOME_DIR/.zshrc" 2>/dev/null || \
       grep -q 'export EDITOR' "$HOME_DIR/.zshrc" 2>/dev/null; then
        pass "~/.zshrc sets EDITOR"
    else
        warn "~/.zshrc does not set EDITOR"
    fi
fi

# Check hyprland.conf sources subconfigs
if [[ -f "$HOME_DIR/.config/hypr/hyprland.conf" ]]; then
    SUBCONFIGS=("monitors" "input" "appearance" "bindings" "autostart" "rules")
    for subconf in "${SUBCONFIGS[@]}"; do
        if grep -q "source.*${subconf}" "$HOME_DIR/.config/hypr/hyprland.conf" 2>/dev/null; then
            pass "hyprland.conf sources ${subconf}.conf"
        else
            fail "hyprland.conf does NOT source ${subconf}.conf"
        fi
    done
fi

# Check autostart.conf references waybar and notification daemon
if [[ -f "$HOME_DIR/.config/hypr/autostart.conf" ]]; then
    if grep -q "waybar" "$HOME_DIR/.config/hypr/autostart.conf" 2>/dev/null; then
        pass "autostart.conf references waybar"
    else
        fail "autostart.conf does NOT reference waybar"
    fi

    if grep -q "mako\|dunst\|swaync" "$HOME_DIR/.config/hypr/autostart.conf" 2>/dev/null; then
        pass "autostart.conf references a notification daemon"
    else
        warn "autostart.conf does not reference a notification daemon (mako/dunst/swaync)"
    fi
fi

echo ""

# =======================
# 4. Template Rendering Check
# =======================
echo "Checking for unrendered templates..."

TEMPLATE_CHECK_DIRS=(
    "$HOME_DIR/.config"
    "$HOME_DIR/.local/bin"
    "$HOME_DIR/.zshrc"
)

UNRENDERED_FOUND=0
for check_path in "${TEMPLATE_CHECK_DIRS[@]}"; do
    if [[ -e "$check_path" ]]; then
        # Look for chezmoi template patterns
        if grep -rq '{{ \.chezmoi\|{{- if\|{{ if\|{{- end\|{{ end' "$check_path" 2>/dev/null; then
            fail "Unrendered chezmoi template found in $check_path"
            UNRENDERED_FOUND=1
        fi
    fi
done

if [[ $UNRENDERED_FOUND -eq 0 ]]; then
    pass "No unrendered chezmoi templates found"
fi

echo ""

# =======================
# 5. Chezmoi State Check
# =======================
echo "Checking chezmoi state..."

if command -v chezmoi &>/dev/null; then
    # Check if chezmoi is initialized
    if chezmoi data &>/dev/null; then
        pass "chezmoi is initialized"

        # Check for pending changes
        if CHEZMOI_STATUS=$(chezmoi status 2>/dev/null); then
            if [[ -z "$CHEZMOI_STATUS" ]]; then
                pass "chezmoi status shows no pending changes"
            else
                warn "chezmoi has pending changes:"
                echo "$CHEZMOI_STATUS" | head -10 | sed 's/^/      /'
                if [[ $(echo "$CHEZMOI_STATUS" | wc -l) -gt 10 ]]; then
                    echo "      ... (truncated)"
                fi
            fi
        else
            warn "Could not check chezmoi status"
        fi

        # Run chezmoi verify
        if chezmoi verify &>/dev/null; then
            pass "chezmoi verify passed"
        else
            fail "chezmoi verify failed"
        fi
    else
        warn "chezmoi is not initialized"
    fi
else
    warn "chezmoi command not found"
fi

echo ""

# =======================
# Summary
# =======================
echo "=== Summary ==="
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"

if [[ $ERRORS -gt 0 ]]; then
    echo ""
    echo "Some checks failed. Review errors above."
    # Only prompt if running interactively
    if [[ -t 0 ]]; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborting. Run 'chezmoi apply -v' to fix issues."
            exit 1
        fi
    else
        exit 1
    fi
elif [[ $WARNINGS -gt 0 ]]; then
    echo ""
    echo "All critical checks passed with warnings."
else
    echo ""
    echo "All checks passed!"
fi
