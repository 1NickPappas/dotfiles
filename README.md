# Arch Linux Bootstrap Repository

Automated Arch Linux installation with:
- **btrfs** filesystem with subvolumes for snapshots
- **LUKS2** full disk encryption
- **GRUB** bootloader with encrypted /boot
- **NetworkManager** for network management

## Quick Start

1. Boot from Arch Linux ISO
2. Copy configuration files to the live environment
3. Create your credentials file:
   ```bash
   cp archinstall/creds.json.example archinstall/creds.json
   vim archinstall/creds.json  # Set your passwords
   ```
4. Run archinstall:
   ```bash
   archinstall --config archinstall/config.json --creds archinstall/creds.json
   ```

## Repository Structure

```
.
├── README.md                     # This file
└── archinstall/
    ├── config.json               # Main archinstall configuration
    ├── creds.json.example        # Credentials template
    └── README.md                 # Detailed archinstall instructions
```

## Disk Layout

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

## Installed Packages

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

## Post-Installation

After first boot:
1. Login as your user
2. Enable NetworkManager: `sudo systemctl enable --now NetworkManager`
3. Connect to network: `nmcli device wifi connect <SSID> password <password>`
4. Install yay for AUR access
5. Install additional packages as needed

## Security Notes

- `creds.json` is gitignored - never commit passwords
- LUKS2 with PBKDF2 is used for GRUB compatibility
- Consider using a strong passphrase for disk encryption
