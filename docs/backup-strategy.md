# Backup Strategy Documentation

## Overview
Automated backup system for Parachini-HomeLab configuration files, API keys, and service databases.

## What Gets Backed Up
- **`config/`** - All service configurations, databases, settings (~250MB compressed)
- **`.env`** - Credentials and API keys

## What Doesn't Get Backed Up
- `data/downloads/` - Temporary download files
- `/mnt/nas/media/` - Your actual media library (backed up separately on NAS)
- Docker images - Can be re-downloaded

## Backup Schedule
**Daily at 4:00 AM CST** via cron job

## Retention Policy
- **Last 7 days**: Keep all daily backups
- **Monthly archives**: Keep one backup from the 1st of each month indefinitely
- **Manual backups**: Pre-update backups are kept separately and never auto-deleted

### Example Retention
```
Today: Jan 26, 2026

KEPT:
- homelab-20260126.tar.gz (today)
- homelab-20260125.tar.gz (1 day old)
- homelab-20260124.tar.gz (2 days old)
- homelab-20260123.tar.gz (3 days old)
- homelab-20260122.tar.gz (4 days old)
- homelab-20260121.tar.gz (5 days old)
- homelab-20260120.tar.gz (6 days old)
- homelab-20260119.tar.gz (7 days old)
- homelab-20260101.tar.gz (monthly - kept forever)
- homelab-20251201.tar.gz (monthly - kept forever)
- homelab-before-update-20260115-143022.tar.gz (manual - kept forever)

DELETED:
- homelab-20260118.tar.gz (8 days old, not 1st of month)
- homelab-20260117.tar.gz (9 days old, not 1st of month)
```

## Backup Location
**NAS Path**: `/mnt/nas/backups/homelab-config/`

## Available Scripts

### 1. `backup-config.sh` - Daily Automated Backup
**When it runs**: Automatically at 4am CST (cron)  
**What it does**:
- Creates compressed archive: `homelab-YYYYMMDD.tar.gz`
- Applies retention policy (deletes old backups)
- Logs to `/home/joe/Parachini-HomeLab/logs/backup.log`

**Manual usage**:
```bash
cd /home/joe/Parachini-HomeLab
./scripts/backup-config.sh
```

### 2. `backup-before-update.sh` - Pre-Update Backup
**When to use**: Before making changes (updates, config edits, experiments)  
**What it does**:
- Creates timestamped backup: `homelab-before-update-YYYYMMDD-HHMMSS.tar.gz`
- Optionally saves reason to `.txt` file
- **Never auto-deleted** - you control cleanup

**Usage**:
```bash
cd /home/joe/Parachini-HomeLab
./scripts/backup-before-update.sh
```

**Example workflow**:
```bash
# Before updating containers
./scripts/backup-before-update.sh
# Reason: "Before updating Sonarr to v4.0"

docker-compose pull
docker-compose up -d

# If something breaks, restore from backup
```

### 3. `restore-config.sh` - Restore from Backup
**When to use**: Disaster recovery, undo changes, rollback after failed update  
**What it does**:
- Shows list of available backups
- Creates emergency backup of current state before restore
- Stops containers
- Replaces config with selected backup
- Restarts containers

**Usage**:
```bash
cd /home/joe/Parachini-HomeLab
./scripts/restore-config.sh
```

**Interactive prompts**:
1. Select backup number
2. Confirm with "yes"
3. Choose whether to delete old config after restore

**⚠️ Safety Features**:
- Always creates emergency backup first
- Requires explicit "yes" confirmation
- Keeps old config as `config.old` until you confirm deletion

## Backup Size
- Typical backup: ~250MB compressed
- 7 daily + monthlies: ~2GB storage
- 10 manual backups: ~2.5GB
- **Total estimate**: ~5GB for backup storage

## Viewing Backup Logs
```bash
# View recent backup activity
tail -50 /home/joe/Parachini-HomeLab/logs/backup.log

# Watch live (during manual backup)
tail -f /home/joe/Parachini-HomeLab/logs/backup.log
```

## Cron Schedule
View current schedule:
```bash
crontab -l
```

Edit schedule:
```bash
crontab -e
```

Current setting: `0 4 * * *` = 4:00 AM daily

## Manual Backup Cleanup
Pre-update backups accumulate over time. Clean them up manually:

```bash
# List manual backups
ls -lh /mnt/nas/backups/homelab-config/homelab-before-update-*

# Delete specific backup
rm /mnt/nas/backups/homelab-config/homelab-before-update-20260115-143022.tar.gz

# Delete all manual backups older than 90 days
find /mnt/nas/backups/homelab-config/ -name "homelab-before-update-*.tar.gz" -mtime +90 -delete
```

## Testing Your Backup
Periodically test restore process:

```bash
# 1. Create test backup
./scripts/backup-before-update.sh
# Reason: "Restore test"

# 2. Make a small change (e.g., edit a file in config/)

# 3. Restore from test backup
./scripts/restore-config.sh

# 4. Verify services still work
docker-compose ps
```

## Disaster Recovery Scenario
**If your entire server dies:**

1. **Set up new server** with Docker
2. **Mount NAS** to `/mnt/nas`
3. **Clone repository**:
   ```bash
   git clone <your-repo> /home/joe/Parachini-HomeLab
   cd /home/joe/Parachini-HomeLab
   ```
4. **Restore latest backup**:
   ```bash
   # Manual restore since scripts need config to run
   tar -xzf /mnt/nas/backups/homelab-config/homelab-YYYYMMDD.tar.gz
   ```
5. **Start services**:
   ```bash
   docker-compose up -d
   ```
6. **Verify** everything works

**Recovery time**: ~30 minutes (assuming Docker already installed)

## Troubleshooting

### Backup fails with "NAS not mounted"
```bash
# Check mount
mountpoint /mnt/nas

# Remount if needed
sudo mount -a
```

### Backup size growing unexpectedly
Some services create large databases over time:
```bash
# Check config size
du -sh /home/joe/Parachini-HomeLab/config/*

# Common culprits:
# - Sonarr/Radarr databases (can grow to 1GB+ with large libraries)
# - SABnzbd logs/history
```

### Out of space on NAS
```bash
# Check backup directory size
du -sh /mnt/nas/backups/homelab-config/

# Remove old manual backups
find /mnt/nas/backups/homelab-config/ -name "homelab-before-update-*.tar.gz" -mtime +30 -delete
```

## Best Practices

1. **Before any major change**: Run `backup-before-update.sh`
2. **Test restores quarterly**: Make sure your backups actually work
3. **Monitor backup logs**: Check for failures monthly
4. **Document your changes**: Use the "reason" field in pre-update backups
5. **Clean up manual backups**: Delete old pre-update backups after successful changes

## Related Documentation
- [Quick Reference](quick-reference.md) - All service URLs and API keys
- [Configuration Guide](configuration-guide.md) - Service setup steps
