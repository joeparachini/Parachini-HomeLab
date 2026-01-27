#!/bin/bash
# Restore configuration from backup
# Interactive script - use with caution!

set -e

HOMELAB_DIR="/home/joe/Parachini-HomeLab"
BACKUP_DIR="/mnt/nas/backups/homelab-config"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}    Parachini-HomeLab Configuration Restore${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════${NC}"
echo ""

# Check if NAS is mounted
if ! mountpoint -q /mnt/nas; then
    echo -e "${RED}ERROR: NAS not mounted at /mnt/nas${NC}"
    exit 1
fi

# List available backups
echo -e "${GREEN}Available backups:${NC}"
echo ""
backups=($(find "$BACKUP_DIR" -name "homelab-*.tar.gz" -type f | sort -r))

if [ ${#backups[@]} -eq 0 ]; then
    echo -e "${RED}No backups found in $BACKUP_DIR${NC}"
    exit 1
fi

# Display backups with numbers
for i in "${!backups[@]}"; do
    backup_file=$(basename "${backups[$i]}")
    backup_size=$(du -h "${backups[$i]}" | cut -f1)
    backup_date=$(stat -c %y "${backups[$i]}" | cut -d' ' -f1)
    printf "%2d) %s (%s) - Created: %s\n" $((i+1)) "$backup_file" "$backup_size" "$backup_date"
done

echo ""
read -p "Select backup number to restore (or 'q' to quit): " selection

if [ "$selection" = "q" ]; then
    echo "Cancelled."
    exit 0
fi

# Validate selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
    echo -e "${RED}Invalid selection${NC}"
    exit 1
fi

SELECTED_BACKUP="${backups[$((selection-1))]}"
echo ""
echo -e "${YELLOW}Selected: $(basename "$SELECTED_BACKUP")${NC}"
echo ""

# Warning and confirmation
echo -e "${RED}⚠️  WARNING ⚠️${NC}"
echo "This will:"
echo "  1. Stop all Docker containers"
echo "  2. Create emergency backup of current config"
echo "  3. Replace current config with backup"
echo "  4. Restart containers"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${GREEN}Starting restore process...${NC}"

# Step 1: Create emergency backup of current state
echo ""
echo "📦 Creating emergency backup of current config..."
EMERGENCY_BACKUP="$BACKUP_DIR/emergency-backup-${TIMESTAMP}.tar.gz"
tar -czf "$EMERGENCY_BACKUP" -C "$HOMELAB_DIR" config/ .env
echo -e "${GREEN}✅ Emergency backup saved: $(basename "$EMERGENCY_BACKUP")${NC}"

# Step 2: Stop containers
echo ""
echo "🛑 Stopping Docker containers..."
cd "$HOMELAB_DIR"
docker-compose down
echo -e "${GREEN}✅ Containers stopped${NC}"

# Step 3: Backup current config (move to temp)
echo ""
echo "💾 Moving current config to temporary location..."
mv "$HOMELAB_DIR/config" "$HOMELAB_DIR/config.old"
mv "$HOMELAB_DIR/.env" "$HOMELAB_DIR/.env.old"

# Step 4: Extract backup
echo ""
echo "📂 Restoring from backup..."
tar -xzf "$SELECTED_BACKUP" -C "$HOMELAB_DIR"
echo -e "${GREEN}✅ Backup extracted${NC}"

# Step 5: Restart containers
echo ""
echo "🚀 Starting Docker containers..."
docker-compose up -d
echo -e "${GREEN}✅ Containers started${NC}"

# Step 6: Cleanup old config
echo ""
read -p "Delete old config backup (config.old, .env.old)? (y/n): " cleanup
if [ "$cleanup" = "y" ]; then
    rm -rf "$HOMELAB_DIR/config.old" "$HOMELAB_DIR/.env.old"
    echo -e "${GREEN}✅ Old config deleted${NC}"
else
    echo -e "${YELLOW}Old config kept in config.old and .env.old${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Restore complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════${NC}"
echo ""
echo "Emergency backup saved at:"
echo "  $EMERGENCY_BACKUP"
echo ""
echo "Check services: docker-compose ps"
echo "View logs: docker-compose logs -f"
