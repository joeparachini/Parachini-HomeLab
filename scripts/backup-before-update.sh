#!/bin/bash
# Manual backup before updates or major changes
# Creates a timestamped backup that won't be auto-deleted

set -e

HOMELAB_DIR="/home/joe/Parachini-HomeLab"
BACKUP_DIR="/mnt/nas/backups/homelab-config"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="homelab-before-update-${TIMESTAMP}.tar.gz"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}    Pre-Update Backup${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
echo ""

# Optional: Ask for a description
read -p "Reason for backup (optional): " reason

# Check if NAS is mounted
if ! mountpoint -q /mnt/nas; then
    echo "ERROR: NAS not mounted at /mnt/nas"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo ""
echo "Creating backup: $BACKUP_FILE"
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    -C "$HOMELAB_DIR" \
    config/ .env

if [ $? -eq 0 ]; then
    SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}✅ Backup created successfully: $SIZE${NC}"
    
    # Save reason to companion file if provided
    if [ -n "$reason" ]; then
        echo "$reason" > "$BACKUP_DIR/$BACKUP_FILE.txt"
        echo -e "${GREEN}✅ Reason saved to $BACKUP_FILE.txt${NC}"
    fi
    
    echo ""
    echo "Backup location:"
    echo "  $BACKUP_DIR/$BACKUP_FILE"
    echo ""
    echo -e "${GREEN}Safe to proceed with updates!${NC}"
else
    echo "❌ Backup failed!"
    exit 1
fi
