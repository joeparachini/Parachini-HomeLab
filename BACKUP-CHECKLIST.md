# WSL Reinstall Backup Checklist

Purpose: clean checklist for rebuilding after Windows/WSL reinstall.

## Current Status (already complete)
- [x] `config/` has been backed up
- [x] `.env` is included in backup
- [x] Git repo is up to date
- [x] NAS endpoint in fstab is updated to `192.168.1.129`
- [x] Nightly backup script succeeds and includes Guacamole DB dump

---

## Critical Configuration to Preserve

### 1) NAS mount configuration (fstab)
Expected entry:

```fstab
192.168.1.129:/volume1/Parachini-Storage /mnt/nas nfs defaults,_netdev,nfsvers=4 0 0
```

Checklist:
- [ ] Save `/etc/fstab` copy to external/Windows storage
- [ ] Record NAS export path: `/volume1/Parachini-Storage`
- [ ] Record mountpoint: `/mnt/nas`

Helpful command:
```bash
sudo cp /etc/fstab /mnt/c/Users/[YOUR_USERNAME]/Desktop/fstab-homelab-backup
```

### 2) Backup archive location
- [ ] Confirm latest archive exists at:
  - `/mnt/nas/HomeLabData/backups/homelab-config/homelab-YYYYMMDD.tar.gz`
- [ ] Copy at least one known-good archive to secondary location (recommended)

### 3) Guacamole backup behavior
- [ ] Confirm restore notes include this detail:
  - Raw `config/guacamole/postgres` is excluded from archive
  - Guacamole data is included as logical dump:
    - `logs/backup-tmp/guacamole-db-YYYYMMDD.sql.gz`

---

## Pre-Reinstall Verification

Run and verify:

```bash
# 1) Verify NAS mount is active and responsive
mount | grep ' /mnt/nas '
timeout 10s ls -lah /mnt/nas | head

# 2) Verify latest backup file exists
ls -1t /mnt/nas/HomeLabData/backups/homelab-config/homelab-*.tar.gz | head -n 3

# 3) Verify latest backup includes Guacamole dump
LATEST=$(ls -1t /mnt/nas/HomeLabData/backups/homelab-config/homelab-*.tar.gz | head -n1)
tar -tzf "$LATEST" | grep -E 'logs/backup-tmp/guacamole-db-[0-9]{8}\.sql\.gz'
```

Checklist:
- [ ] Mount check passes (no timeout)
- [ ] Latest archive is present
- [ ] Guacamole dump exists inside archive
- [ ] Backup copy stored outside WSL filesystem

---

## Restore Steps After Reinstall

### 1) Recreate mountpoint and fstab
```bash
sudo mkdir -p /mnt/nas
sudo nano /etc/fstab
# Add:
# 192.168.1.129:/volume1/Parachini-Storage /mnt/nas nfs defaults,_netdev,nfsvers=4 0 0
```

### 2) Reload and mount
```bash
sudo systemctl daemon-reload
sudo mount -a
mount | grep ' /mnt/nas '
timeout 10s ls -lah /mnt/nas | head
```

### 3) Restore homelab repo and backup
```bash
cd ~
git clone https://github.com/joeparachini/Parachini-HomeLab.git
cd Parachini-HomeLab

# Restore config and .env from archive
sudo tar -xzf /mnt/nas/HomeLabData/backups/homelab-config/homelab-YYYYMMDD.tar.gz -C /home/joe/Parachini-HomeLab
```

### 4) Start stack
```bash
cd /home/joe/Parachini-HomeLab
docker-compose up -d
```

### 5) Validate backups still work
```bash
./scripts/backup-config.sh
tail -n 50 /home/joe/Parachini-HomeLab/logs/backup.log
```

Checklist:
- [ ] Services start successfully
- [ ] NAS mount remains responsive
- [ ] Backup script completes successfully
- [ ] Log shows Guacamole dump creation and backup success

---

## Quick Troubleshooting

### If `mount -a` warns about stale systemd fstab cache
```bash
sudo systemctl daemon-reload
sudo mount -a
```

### If `/mnt/nas` is mounted but hangs
```bash
sudo umount -l /mnt/nas
sudo systemctl daemon-reload
sudo mount -a
timeout 10s ls -lah /mnt/nas | head
```

### If backup fails due to NAS state
- Expected behavior now is fast failure with a timeout error (no indefinite hang).
- Fix mount first, then rerun:
```bash
cd /home/joe/Parachini-HomeLab
./scripts/backup-config.sh
```
