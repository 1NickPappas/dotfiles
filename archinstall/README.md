# archinstall Configuration

Two installation methods:
- **Manual (Interactive)** - Run `archinstall` and configure via menus
- **Automated (Config Files)** - Use pre-made config files for repeatable installs

---

## Method 1: Manual Installation (Recommended for First Time)

### 1. Boot from Arch ISO

Download from https://archlinux.org/download/ and boot.

### 2. Connect to Internet

```bash
# Wired connection should work automatically
# For WiFi:
iwctl
[iwd]# station wlan0 connect <SSID>
```

### 3. Run archinstall

```bash
archinstall
```

### 4. Configure via Menu

| Setting | Recommended |
|---------|-------------|
| Mirrors | Select your region |
| Disk configuration | Select drive, use btrfs, enable encryption |
| Disk encryption | Set a strong LUKS password |
| Bootloader | GRUB (for encryption support) |
| Hostname | Your machine name |
| Root password | Skip (use sudo instead) |
| User account | Create user with sudo privileges |
| Profile | Desktop → KDE or your preference |
| Audio | **pipewire** (modern) |
| Kernel | linux (or linux-zen for desktop) |
| Network | NetworkManager |
| Timezone | Your timezone |

### 5. Save Configuration (Optional)

Before installing, select **Save configuration** to export:
- `user_configuration.json` - General config
- `user_credentials.json` - Encrypted credentials

These are saved to `/var/log/archinstall/` and can be reused for future installs.

### 6. Install

Select **Install** and wait for completion. Reboot when done.

### 7. Post-Install Setup

After rebooting into your new system:

```bash
# Check network connectivity
ping -c 3 archlinux.org

# If no connection, start NetworkManager
sudo systemctl enable --now NetworkManager

# For WiFi
nmcli device wifi list
nmcli device wifi connect "YourSSID" password "YourPassword"
```

```bash
# Install git
sudo pacman -S git

# Clone dotfiles
git clone https://github.com/1NickPappas/dotfiles.git
cd dotfiles/scripts

# Make executable and run bootstrap
chmod +x *.sh
./bootstrap.sh
```

Reboot when complete. You'll have your full desktop environment.

---

## Method 2: Automated Installation (Config Files)

Use pre-made config files for repeatable installs.

## Files

- `config.json` - Main archinstall configuration
- `creds.json.example` - Template for credentials (copy to `creds.json`)
- `creds.json` - Your actual credentials (gitignored, create from example)

## Usage

### 1. Boot from Arch ISO

Download from https://archlinux.org/download/ and boot.

### 2. Connect to Internet

```bash
# Wired connection should work automatically
# For WiFi:
iwctl
[iwd]# station wlan0 connect <SSID>
```

### 3. Get Configuration Files

Option A - Clone from GitHub:
```bash
pacman -Sy git
git clone https://github.com/1NickPappas/dotfiles.git
cd arch/archinstall
```

Option B - Copy from USB:
```bash
mount /dev/sdX1 /mnt
cp -r /mnt/archinstall .
umount /mnt
cd archinstall
```

### 4. Create Credentials File

```bash
cp creds.json.example creds.json
vim creds.json
```

**Generate password hash first:**
```bash
openssl passwd -6 'YOUR_PASSWORD'
```

Fill in:
- `encryption-password` - LUKS disk encryption password (plaintext)
- `users[].enc_password` - Paste the hash from above

### 5. Identify Target Disk

```bash
lsblk
# Note your target disk (e.g., /dev/nvme0n1 or /dev/sda)
```

**Important:** Edit `config.json` if your disk is not `/dev/nvme0n1`:
```bash
sed -i 's/nvme0n1/sda/g' config.json
```

### 6. Run archinstall

```bash
archinstall --config config.json --creds creds.json
```

### 7. Post-Install

When prompted, chroot into the new system or reboot.

## Configuration Details

### Disk Layout

| Partition | Size | Type | Mount |
|-----------|------|------|-------|
| p1 | 512MB | FAT32 (ESP) | /boot/efi |
| p2 | Remainder | LUKS2 → btrfs | / |

### btrfs Subvolumes

| Subvolume | Mount Point | Purpose |
|-----------|-------------|---------|
| @ | / | Root filesystem |
| @home | /home | User data |
| @snapshots | /.snapshots | Snapper snapshots |
| @var_log | /var/log | Logs (excluded from snapshots) |
| @swap | /swap | Swapfile location |

### Mount Options

All btrfs subvolumes use:
- `compress=zstd` - Transparent compression
- `noatime` - Reduce disk writes
- `space_cache=v2` - Modern space cache

### Packages

Minimal set for bootable system + AUR support:

```
base linux linux-firmware btrfs-progs
grub efibootmgr networkmanager
base-devel git sudo vim
```

## Troubleshooting

### "Device not found"
- Verify disk name with `lsblk`
- Update device paths in `config.json`

### GRUB fails to decrypt
- LUKS2 with PBKDF2 is required for GRUB
- argon2id (LUKS2 default) is NOT supported by GRUB

### No network after reboot
```bash
sudo systemctl enable --now NetworkManager
nmcli device wifi list
nmcli device wifi connect <SSID> password <password>
```

### Can't sudo
- User must be in `wheel` group
- Check `/etc/sudoers` includes `%wheel ALL=(ALL:ALL) ALL`

### Chezmoi "config file template has changed" warning
Clear chezmoi state and reinitialize:
```bash
rm -rf ~/.config/chezmoi
rm -rf ~/.local/share/chezmoi
chezmoi init --source=~/dotfiles/dotfiles --apply
```

## Customization

### Different Timezone
Edit `config.json`:
```json
"timezone": "America/New_York"
```

### Different Locale
Edit `config.json`:
```json
"locale_config": {
    "kb_layout": "de",
    "sys_lang": "de_DE.UTF-8"
}
```

### Additional Packages
Add to the `packages` array in `config.json`:
```json
"packages": ["base", "linux", ..., "your-package"]
```
