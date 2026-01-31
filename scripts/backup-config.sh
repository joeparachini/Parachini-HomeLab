#!/bin/bash
# Daily backup script for Parachini-HomeLab config
# Runs at 4am CST via cron

set -e

# Configuration
HOMELAB_DIR="/home/joe/Parachini-HomeLab"
BACKUP_DIR="/mnt/nas/HomeLabData/backups/homelab-config"
DATE=$(date +%Y%m%d)
BACKUP_FILE="homelab-${DATE}.tar.gz"
LOG_FILE="$HOMELAB_DIR/logs/backup.log"

# Create log directory if it doesn't exist
mkdir -p "$HOMELAB_DIR/logs"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting backup ==="

# Check if NAS is mounted
if ! mountpoint -q /mnt/nas; then
    log "ERROR: NAS not mounted at /mnt/nas"
    exit 1
fi

# Create backup directory if needed
mkdir -p "$BACKUP_DIR"

# Create backup (only if one doesn't exist for today)
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    log "Backup already exists for today: $BACKUP_FILE"
else
    log "Creating backup: $BACKUP_FILE"
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
        -C "$HOMELAB_DIR" \
        config/ .env \
        2>&1 | tee -a "$LOG_FILE"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
        log "✅ Backup created successfully: $SIZE"
    else
        log "❌ Backup failed!"
        exit 1
    fi
fi

# Retention: Delete daily backups older than 7 days, but keep monthly (1st of month)
log "Applying retention policy..."
find "$BACKUP_DIR" -name "homelab-????????.tar.gz" -type f | while read -r backup; do
    filename=$(basename "$backup")
    # Extract date from filename (homelab-YYYYMMDD.tar.gz)
    backup_date=$(echo "$filename" | grep -oP '\d{8}')
    day_of_month=$(echo "$backup_date" | cut -c7-8)
    
    # Calculate age in days
    backup_epoch=$(date -d "$backup_date" +%s)
    current_epoch=$(date +%s)
    age_days=$(( (current_epoch - backup_epoch) / 86400 ))
    
    # Keep if less than 7 days old OR if it's from the 1st of the month
    if [ $age_days -gt 7 ] && [ "$day_of_month" != "01" ]; then
        log "Deleting old backup: $filename (${age_days} days old)"
        rm "$backup"
    fi
done

# Count remaining backups
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "homelab-????????.tar.gz" | wc -l)
log "Total backups retained: $BACKUP_COUNT"

log "=== Backup complete ==="
echo ""  # Blank line for readability
