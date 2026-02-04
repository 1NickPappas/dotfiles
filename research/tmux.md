# Tmux Setup

## Overview

Tmux configuration using TPM (Tmux Plugin Manager) with Catppuccin Mocha theme to match Ghostty, Starship, and Zsh setup.

## Installation

TPM is automatically installed via chezmoi's `run_once_install-tpm.sh` script.

After first tmux launch:
1. Press `prefix + I` to install plugins
2. Reload config: `tmux source ~/.config/tmux/tmux.conf`

## Plugins

| Plugin | Purpose |
|--------|---------|
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sane defaults everyone agrees on |
| [catppuccin/tmux](https://github.com/catppuccin/tmux) | Catppuccin Mocha theme |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save/restore sessions across restarts |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save sessions every 15 min |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | System clipboard integration |

## Key Bindings

| Binding | Action |
|---------|--------|
| `Ctrl+b` | Prefix (default) |
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |
| `prefix + h/j/k/l` | Navigate panes (vim-style) |
| `prefix + [` | Enter copy mode |
| `v` (in copy mode) | Start selection |
| `y` (in copy mode) | Copy to clipboard |
| `prefix + I` | Install plugins |
| `prefix + U` | Update plugins |
| `prefix + Ctrl+s` | Save session (resurrect) |
| `prefix + Ctrl+r` | Restore session (resurrect) |

## TPM Commands

- `prefix + I` - Install new plugins
- `prefix + U` - Update plugins
- `prefix + alt + u` - Uninstall removed plugins

## Configuration

Config location: `~/.config/tmux/tmux.conf`

### Key Settings

```bash
set -g mouse on              # Enable mouse support
set -g base-index 1          # Windows start at 1
setw -g pane-base-index 1    # Panes start at 1
set -g escape-time 0         # No escape delay (important for vim)
setw -g mode-keys vi         # Vi keys in copy mode
```

### Theme

Using Catppuccin Mocha flavor with rounded window status style to match:
- Ghostty terminal
- Starship prompt
- Zsh syntax highlighting

## Files

| File | Location |
|------|----------|
| `dotfiles/dot_config/tmux/tmux.conf` | Main config |
| `dotfiles/run_once_install-tpm.sh` | TPM bootstrap script |

## Resources

- [TPM - Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Catppuccin Tmux Theme](https://github.com/catppuccin/tmux)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [awesome-tmux](https://github.com/rothgar/awesome-tmux)
