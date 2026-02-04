# Zsh Research - Minimal Setup with Starship

## Goal

Create a minimal, fast zsh setup using Starship + essential plugins without a framework like Oh-My-Zsh.

---

## Why This Approach?

| Approach | Startup Time | Complexity | Flexibility |
|----------|--------------|------------|-------------|
| **Starship + manual plugins** | ~50ms | Low | High |
| Zinit + Starship | ~80ms | Medium | High |
| Oh-My-Zsh + Starship | ~200-400ms | Low | Medium |

Starship is written in Rust and is very fast. Since Powerlevel10k is now end-of-life, Starship is the recommended modern prompt.

Sources:
- [Starship Official](https://starship.rs/)
- [Powerlevel10k EOL - Hello Starship](https://hashir.blog/2025/06/powerlevel10k-is-on-life-support-hello-starship/)
- [ZSH + Starship Productivity](https://carlosneto.dev/blog/2024/2024-02-08-starship-zsh/)

---

## Essential Plugins (The Only 3 You Need)

| Plugin | What It Does | Why Essential |
|--------|--------------|---------------|
| **zsh-autosuggestions** | Fish-like suggestions in gray as you type | Life-changing UX |
| **zsh-syntax-highlighting** | Colors commands (green=valid, red=invalid) | Catch typos instantly |
| **zsh-completions** | Additional tab completions | Better completion for tools |

Sources:
- [zsh-autosuggestions GitHub](https://github.com/zsh-users/zsh-autosuggestions)
- [The Only 6 Zsh Plugins You Need](https://catalins.tech/zsh-plugins/)

---

## Installation on Arch Linux

All three plugins are available in the official repos:

```bash
# Already in packages/base.txt
sudo pacman -S zsh starship

# Add to packages/base.txt
sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

The packages install to:
- `/usr/share/zsh/plugins/zsh-autosuggestions/`
- `/usr/share/zsh/plugins/zsh-syntax-highlighting/`
- `/usr/share/zsh/site-functions/` (completions)

---

## Cross-Platform Considerations (macOS vs Linux)

For chezmoi templates, handle the different plugin paths:

```zsh
# In dot_zshrc.tmpl
{{ if eq .chezmoi.os "darwin" -}}
# macOS - Homebrew paths
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
{{ else -}}
# Linux (Arch) - pacman paths
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
{{ end -}}
```

---

## Vi Mode Reference

| Key | Mode | Action |
|-----|------|--------|
| `Esc` or `jk` | Insert → Normal | Exit insert mode |
| `i` | Normal → Insert | Enter insert mode |
| `a` | Normal → Insert | Enter insert mode after cursor |
| `k` / `j` | Normal | Search history backward/forward |
| `0` / `$` | Normal | Go to start/end of line |
| `w` / `b` | Normal | Forward/backward word |
| `Ctrl+Space` | Insert | Accept autosuggestion |
| `Ctrl+f` | Insert | Accept autosuggestion (fish-style) |

Cursor changes: **Block** = normal mode, **Beam** = insert mode

Sources:
- [Manual vi mode cursor change](https://linux.codidact.com/posts/287822)
- [zsh-vi-mode plugin](https://github.com/jeffreytse/zsh-vi-mode) (alternative if you want more features)

---

## fzf Integration

fzf provides fuzzy finding for history, files, and directories. Already installed via `packages/base.txt`.

| Keybinding | Action |
|------------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files in current directory |
| `Alt+C` | Fuzzy change directory |

Shell integration files:
- **Arch Linux**: `/usr/share/fzf/key-bindings.zsh` and `/usr/share/fzf/completion.zsh`
- **macOS (Homebrew)**: `$(brew --prefix)/opt/fzf/shell/key-bindings.zsh` and `completion.zsh`

Sources:
- [fzf ArchWiki](https://wiki.archlinux.org/title/Fzf)
- [fzf Shell Integration](https://junegunn.github.io/fzf/shell-integration/)

---

## Verification

After applying:
1. Open new terminal - cursor should be beam (insert mode)
2. Type `ls` slowly - should see gray autosuggestion
3. Type `lss` (typo) - should be red
4. Type `ls` - should be green
5. Press `Esc` - cursor changes to block (normal mode)
6. Press `i` - cursor changes back to beam
7. Press Tab - should see completions
8. Prompt should show directory + git info
9. Press `Ctrl+R` - should open fuzzy history search
10. Press `Ctrl+T` - should show file picker
11. Press `Alt+C` - should show directory picker

---

## Configuration Files

See:
- `dotfiles/dot_zshrc.tmpl` - Full zsh configuration
- `dotfiles/dot_config/starship.toml` - Starship prompt configuration
