# Arch Linux Bootstrap Repository

Automated Arch Linux installation and chezmoi-managed dotfiles.

---

## 1. Dotfiles on macOS

Quick setup for macOS users. Cross-platform configs only (zsh, starship, tmux, nvim, git, ghostty, btop, lazygit). Linux-only configs like Hyprland are automatically excluded via `.chezmoiignore`.

```bash
# One-liner install
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply 1NickPappas/dotfiles --source=dotfiles
```

---

## 2. Dotfiles on Arch Linux

For existing Arch installations - apply full dotfiles including Hyprland:

```bash
# Install chezmoi and apply
sudo pacman -S chezmoi
chezmoi init --apply 1NickPappas/dotfiles --source=dotfiles
```

**Applying from a local clone:**

```bash
# If you have the repo cloned locally
chezmoi apply --source ~/path/to/dotfiles
```

---

## 3. Fresh Arch Install (USB to Desktop)

Complete walkthrough for installing Arch Linux from scratch.

### Step 1: Boot Arch ISO from USB

Download from https://archlinux.org/download/ and boot.

### Step 2: Connect to WiFi

Skip if using ethernet (should work automatically).

```bash
# List WiFi devices
iwctl device list

# Scan and show available networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks

# Connect to your network
iwctl --passphrase "YourPassword" station wlan0 connect "YourSSID"

# Test connection
ping -c 3 archlinux.org
```

### Step 3: Clone this repo

```bash
pacman -Sy git
git clone https://github.com/1NickPappas/dotfiles.git
cd dotfiles
```

### Step 4: Create credentials and run archinstall

```bash
cp archinstall/creds.json.example archinstall/creds.json
vim archinstall/creds.json  # Set your passwords
archinstall --config archinstall/config.json --creds archinstall/creds.json
```

### Step 5: First boot - run bootstrap

```bash
cd dotfiles/scripts
./bootstrap.sh
```

This automatically cleans up archinstall credential logs.

---

## Technical Details

### Archinstall Features

- **btrfs** filesystem with subvolumes for snapshots
- **LUKS2** full disk encryption
- **GRUB** bootloader with encrypted /boot
- **NetworkManager** for network management

### Dotfiles Features

- **Hyprland** window manager with modular config
- **Catppuccin Mocha** theme (with Nord, Gruvbox, Tokyo Night available)
- **zsh** + **starship** prompt
- **ghostty** terminal + **tmux**

### Repository Structure

```
.
├── README.md
├── archinstall/
│   ├── config.json               # Main archinstall configuration
│   ├── creds.json.example        # Credentials template
│   └── README.md                 # Detailed archinstall instructions
└── dotfiles/                     # Chezmoi source directory
    ├── .chezmoidata/
    │   └── themes.toml           # Theme color definitions
    ├── .chezmoi.toml.tmpl        # Chezmoi configuration template
    ├── dot_zshrc.tmpl            # Zsh configuration
    ├── dot_gitconfig             # Git configuration
    ├── dot_config/
    │   ├── hypr/                 # Hyprland (modular config)
    │   ├── waybar/               # Status bar
    │   ├── ghostty/              # Terminal emulator
    │   ├── tmux/                 # Terminal multiplexer
    │   ├── nvim/                 # Neovim
    │   ├── mako/                 # Notifications
    │   ├── walker/               # Application launcher
    │   ├── btop/                 # System monitor
    │   ├── lazygit/              # Git TUI
    │   ├── swayosd/              # OSD for volume/brightness
    │   ├── fontconfig/           # Font configuration
    │   └── starship.toml         # Shell prompt
    ├── dot_local/bin/            # Utility scripts
    │   ├── screenshot
    │   ├── screenrecord
    │   ├── volume-control
    │   ├── brightness-control
    │   └── theme-set
    └── run_once_install-tpm.sh   # TPM installer for tmux
```

### Disk Layout

```
/dev/nvme0n1 (or /dev/sda)
├── p1: ESP (512MB, FAT32, unencrypted)
│   └── EFI/GRUB/grubx64.efi
│
└── p2: LUKS2 encrypted partition (remainder)
    └── btrfs filesystem
        ├── @           → /
        ├── @home       → /home
        ├── @snapshots  → /.snapshots
        ├── @var_log    → /var/log
        └── @swap       → /swap
```

### Installed Packages

Minimal 11-package set for a bootable system:

| Package | Purpose |
|---------|---------|
| base | Core system |
| linux | Kernel |
| linux-firmware | Hardware firmware |
| btrfs-progs | btrfs utilities |
| grub | Bootloader |
| efibootmgr | UEFI boot manager |
| networkmanager | Network connectivity |
| base-devel | Build tools for AUR |
| git | Clone repos |
| sudo | User privileges |
| vim | Text editor |

### Theming

All theme colors are centralized in `.chezmoidata/themes.toml`. Configs that support theming use chezmoi templates (`.tmpl` files) to apply colors consistently.

**Available themes:**
- Catppuccin Mocha (default)
- Nord
- Gruvbox
- Tokyo Night

To change themes, edit `.chezmoi.toml.tmpl` and set your preferred theme name, then run `chezmoi apply`.

### Utility Scripts

Located in `~/.local/bin/` after applying:

| Script | Description |
|--------|-------------|
| `screenshot` | Screenshot capture (area, window, fullscreen) |
| `screenrecord` | Screen recording with wf-recorder |
| `volume-control` | Volume adjustment with OSD |
| `brightness-control` | Brightness adjustment with OSD |
| `theme-set` | Switch between themes |

## Security Notes

- `creds.json` is gitignored - never commit passwords
- LUKS2 with PBKDF2 is used for GRUB compatibility
- Consider using a strong passphrase for disk encryption
- Archinstall credential logs are automatically removed by `bootstrap.sh`
