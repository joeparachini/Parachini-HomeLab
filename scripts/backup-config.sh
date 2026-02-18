#!/bin/bash
# Daily backup script for Parachini-HomeLab config
# Runs at 4am CST via cron

set -e
set -o pipefail

# Configuration
HOMELAB_DIR="/home/joe/Parachini-HomeLab"
BACKUP_DIR="/mnt/nas/HomeLabData/backups/homelab-config"
DATE=$(date +%Y%m%d)
BACKUP_FILE="homelab-${DATE}.tar.gz"
LOG_FILE="$HOMELAB_DIR/logs/backup.log"
GUAC_DB_CONTAINER="guacamole-db"
GUAC_DB_DUMP_REL="logs/backup-tmp/guacamole-db-${DATE}.sql.gz"

# Create log directory if it doesn't exist
mkdir -p "$HOMELAB_DIR/logs"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== Starting backup ==="

# Check if NAS is mounted (timeout prevents hangs on stale NFS mounts)
if timeout 10s mountpoint -q /mnt/nas; then
    :
else
    mount_status=$?
    if [ $mount_status -eq 124 ]; then
        log "ERROR: NAS mount check timed out at /mnt/nas"
    else
        log "ERROR: NAS not mounted at /mnt/nas"
    fi
    exit 1
fi

# Create backup directory if needed
if ! timeout 15s mkdir -p "$BACKUP_DIR"; then
    log "ERROR: Unable to access backup directory: $BACKUP_DIR"
    exit 1
fi

# Create temporary folder and ensure dump cleanup
mkdir -p "$HOMELAB_DIR/logs/backup-tmp"
cleanup() {
    rm -f "$HOMELAB_DIR/$GUAC_DB_DUMP_REL"
}
trap cleanup EXIT

# Guacamole postgres data uses restricted permissions; back it up via pg_dump instead
if docker ps --format '{{.Names}}' | grep -qx "$GUAC_DB_CONTAINER"; then
    log "Creating Guacamole database dump..."
    if timeout 120s docker exec "$GUAC_DB_CONTAINER" pg_dump -U guacamole guacamole_db 2>>"$LOG_FILE" | gzip > "$HOMELAB_DIR/$GUAC_DB_DUMP_REL"; then
        log "✅ Guacamole database dump created"
    else
        log "⚠️ Guacamole database dump failed; continuing with config backup"
        rm -f "$HOMELAB_DIR/$GUAC_DB_DUMP_REL"
    fi
else
    log "⚠️ Guacamole DB container not running; continuing with config backup"
fi

# Create backup (only if one doesn't exist for today)
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    log "Backup already exists for today: $BACKUP_FILE"
else
    TAR_ITEMS=(config/ .env)
    if [ -f "$HOMELAB_DIR/$GUAC_DB_DUMP_REL" ]; then
        TAR_ITEMS+=("$GUAC_DB_DUMP_REL")
    fi

    log "Creating backup: $BACKUP_FILE"
    timeout 1800s tar --exclude='config/guacamole/postgres' -czf "$BACKUP_DIR/$BACKUP_FILE" \
        -C "$HOMELAB_DIR" \
        "${TAR_ITEMS[@]}" \
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
