# Arch Linux Bootstrap Scripts

Post-installation scripts for setting up an Arch Linux system with Hyprland.

## Usage

Run the main bootstrap script after a fresh Arch install:

```bash
./bootstrap.sh
```

This will:
1. Ask if you want to create a btrfs snapshot (skip after rollback)
2. Install yay (AUR helper)
3. Install all packages from package lists
4. Apply dotfiles using chezmoi
5. Configure Hyprland to auto-start on boot

After running: reboot → Hyprland starts automatically.

## Individual Scripts

You can also run scripts individually:

- `01-snapshot.sh` - Create btrfs snapshot before changes
- `02-yay.sh` - Install yay AUR helper
- `03-packages.sh` - Install packages from lists
- `04-chezmoi.sh` - Initialize and apply dotfiles, set zsh as default shell
- `05-hyprland-autostart.sh` - Configure Hyprland to auto-start on tty1

## Package Lists

Edit the package lists in `../packages/`:

- `base.txt` - Essential CLI tools
- `desktop.txt` - Hyprland + Wayland stack
- `aur.txt` - AUR packages

## Testing with btrfs Snapshots

### Create test snapshot
```bash
sudo btrfs subvolume snapshot / /.snapshots/pre-test-$(date +%Y%m%d-%H%M%S)
```

### List snapshots
```bash
sudo btrfs subvolume list /.snapshots
```

### Rollback to snapshot
Boot from Arch ISO, then:
```bash
# Mount btrfs root
sudo mount /dev/mapper/cryptroot /mnt -o subvolid=5

# Delete current @ and replace with snapshot
sudo btrfs subvolume delete /mnt/@
sudo btrfs subvolume snapshot /mnt/@snapshots/pre-test-XXXXXX /mnt/@

# Reboot
sudo reboot
```

## Cross-Platform Dotfiles

The dotfiles use chezmoi templates for cross-platform support:

- **Arch Linux**: Full config including Hyprland, Waybar, Wofi
- **macOS**: Shared configs (zsh, nvim, ghostty) without Linux-specific ones

To apply dotfiles on macOS:
```bash
chezmoi init --source=../dotfiles
chezmoi apply
```

## Keybindings (Hyprland)

| Binding | Action |
|---------|--------|
| `Super + Return` | Open terminal (ghostty) |
| `Super + D` | Application launcher (wofi) |
| `Super + Q` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + F` | Fullscreen |
| `Super + V` | Toggle floating |
| `Print` | Screenshot region |
| `Shift + Print` | Screenshot full screen |
