# 🔄 WSL Reinstall Backup Checklist

**Date Created:** 2026-02-18  
**Purpose:** Backup checklist before fresh Windows install (will wipe WSL)

---

## ✅ Critical Items to Backup

### 1. **Configuration Files** (~1.3GB)
- [ ] **Entire `config/` directory** - Contains all service configurations, API keys, databases
  - Location: `/home/joe/Parachini-HomeLab/config/`
  - Includes: Prowlarr, Sonarr, Radarr, Lidarr, SABnzbd, Jellyfin, Overseerr, Bazarr, Homepage, Guacamole DB, etc.
  - **CRITICAL**: This contains all your indexers, quality profiles, download client settings, and API integrations

### 2. **Environment File** (REQUIRED)
- [ ] **`.env` file** - Contains all secrets and credentials
  - Location: `/home/joe/Parachini-HomeLab/.env`
  - Contains: VPN keys, Usenet credentials, API keys, paths, timezone
  - **DO NOT commit to Git** - This is gitignored for security

### 3. **Git Repository**
- [ ] Ensure all changes are committed and pushed to GitHub
  - Current uncommitted changes detected:
    - Modified: `docker-compose.yml`
    - Untracked: Several backup files and `docs/guacamole-setup.md`
  - Remote: https://github.com/joeparachini/Parachini-HomeLab.git
  - **Action needed**: Review and commit/push changes

### 4. **Media Library** (if stored in WSL)
- [ ] Check where your media is stored (MEDIA_PATH in .env)
  - If media is in WSL: **MUST backup immediately**
  - If media is on Windows drive or NAS: Already safe, just note the path

### 5. **Custom Scripts/Docs**
- [ ] Backup any custom scripts in `scripts/` directory
- [ ] Backup documentation in `docs/` directory
- [ ] Note: `docs/guacamole-setup.md` is currently untracked

---

## 📋 Backup Procedure

### Option A: Quick External Backup (Recommended)
```bash
# Create a timestamped backup archive
cd /home/joe
tar -czf Parachini-HomeLab-backup-$(date +%Y%m%d).tar.gz \
  Parachini-HomeLab/config/ \
  Parachini-HomeLab/.env \
  Parachini-HomeLab/docs/ \
  Parachini-HomeLab/scripts/

# Copy to Windows filesystem (accessible after WSL is gone)
cp Parachini-HomeLab-backup-*.tar.gz /mnt/c/Users/[YOUR_USERNAME]/Desktop/
```

### Option B: Cloud Backup
```bash
# Upload config to cloud storage (OneDrive, Google Drive, Dropbox, etc.)
# Or copy to external drive mounted to Windows
```

### Option C: Git Commit Everything
```bash
cd /home/joe/Parachini-HomeLab

# Add all untracked files you want to keep
git add docs/guacamole-setup.md
git add docker-compose.yml

# Create a backup branch with sensitive data (use PRIVATE repo only!)
git checkout -b backup-with-configs
git add -f .env config/  # Force add gitignored files
git commit -m "Backup before WSL reinstall (PRIVATE - contains secrets)"
git push origin backup-with-configs

# Return to main branch
git checkout main
```
**⚠️ WARNING**: Only use Option C if your GitHub repo is PRIVATE!

---

## 🔄 Restore Procedure (After Windows Reinstall)

### 1. Install WSL2 and Docker
```bash
# On fresh Windows install:
wsl --install
# Install Docker Desktop for Windows (includes Docker Compose)
```

### 2. Clone Repository
```bash
cd ~
git clone https://github.com/joeparachini/Parachini-HomeLab.git
cd Parachini-HomeLab
```

### 3. Restore Configurations
```bash
# Extract backup archive
tar -xzf Parachini-HomeLab-backup-YYYYMMDD.tar.gz

# Or if using git backup branch:
git fetch origin backup-with-configs
git checkout backup-with-configs
git checkout main  # Return to main but keep files
```

### 4. Update Paths in .env
```bash
nano .env
# Update these if changed:
# - MEDIA_PATH (point to new Windows mount location)
# - Any other paths that might have changed
```

### 5. Verify User IDs Match
```bash
id  # Should show uid=1000(joe) gid=1000(joe)
# If different, update PUID/PGID in .env
```

### 6. Start Services
```bash
docker-compose up -d
```

### 7. Verify Everything Works
- Check all services are accessible at their ports
- Verify Jellyfin can see media files
- Test a download through SABnzbd
- Confirm Cloudflare tunnel is working (if using remote access)

---

## 📝 Important Notes

### What's Safe (Already Backed Up)
- ✅ Docker images (will re-download automatically)
- ✅ `docker-compose.yml` (in Git)
- ✅ `.env.example` (in Git)
- ✅ Scripts and docs (in Git if committed)

### What's NOT Safe (Must Backup Manually)
- ❌ `.env` file (gitignored - contains secrets)
- ❌ `config/` directory (gitignored - contains all service data)
- ❌ Any media stored in WSL (if applicable)
- ❌ Uncommitted changes

### Services With Important Data in Config
- **Prowlarr**: All indexer configurations and API keys
- **Sonarr/Radarr/Lidarr**: Series/movie databases, quality profiles, naming schemes
- **SABnzbd**: Download history, categories, scripts
- **Jellyfin**: User accounts, watch history, metadata
- **Overseerr**: User requests and permissions
- **Guacamole**: PostgreSQL database with connection configs
- **Homepage**: Dashboard layout and widget configurations

---

## 🆘 Emergency Contacts

- GitHub Repo: https://github.com/joeparachini/Parachini-HomeLab.git
- Docker Hub: All images from linuxserver.io and official sources
- TRaSH Guides: https://trash-guides.info/ (for rebuilding quality profiles)

---

## ✅ Pre-Reinstall Verification

Before wiping Windows, verify:
- [ ] `.env` file is backed up to Windows filesystem
- [ ] `config/` directory is backed up (1.3GB)
- [ ] All important git changes are committed and pushed
- [ ] Media files location is documented (if on WSL, backed up)
- [ ] You have your Windows PC's hostname/IP for future configs
- [ ] Backup archive is on external storage or Windows filesystem at `/mnt/c/`

**Recommended command to verify backup:**
```bash
# Check backup exists and is readable
tar -tzf /mnt/c/Users/[USERNAME]/Desktop/Parachini-HomeLab-backup-*.tar.gz | head -20
```
