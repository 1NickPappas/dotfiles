#!/bin/bash
# Create btrfs snapshot before making changes (for easy rollback)
set -euo pipefail

SNAPSHOT_DIR="/.snapshots"
SNAPSHOT_NAME="pre-bootstrap-$(date +%Y%m%d-%H%M%S)"

echo "=== Creating btrfs snapshot ==="

# Check if running on btrfs
if ! findmnt -n -o FSTYPE / | grep -q btrfs; then
    echo "Warning: Root filesystem is not btrfs, skipping snapshot"
    exit 0
fi

# Create snapshots directory if it doesn't exist
if [ ! -d "$SNAPSHOT_DIR" ]; then
    echo "Creating $SNAPSHOT_DIR directory..."
    sudo mkdir -p "$SNAPSHOT_DIR"
fi

# Create snapshot
echo "Creating snapshot: $SNAPSHOT_DIR/$SNAPSHOT_NAME"
sudo btrfs subvolume snapshot / "$SNAPSHOT_DIR/$SNAPSHOT_NAME"

echo "Snapshot created successfully!"
echo "To rollback, boot from Arch ISO and restore this snapshot"
