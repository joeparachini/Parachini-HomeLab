# Phase 5: Configuration & Integration Guide

This guide walks you through connecting all services together.

## Prerequisites
All services should be running. Verify:
```bash
docker ps
```

## Step 1: Configure Prowlarr (Indexer Manager)

### 1.1 Access Prowlarr
Open: http://localhost:9696

### 1.2 Complete Setup Wizard
- Set authentication (optional but recommended)
- Click through the wizard

### 1.3 Add Indexers
1. Go to: **Indexers → Add Indexer**
2. Search for your indexers (examples):
   - **NZBGeek** (if you have an account)
   - **NZBFinder** (if you have an account)
   - **NZBPlanet**
   - Or any indexers you have accounts with

3. For each indexer:
   - Enter API key or credentials
   - Test connection
   - Save

### 1.4 Get Prowlarr API Key
1. Go to: **Settings → General**
2. Copy the **API Key**
3. Save it - you'll need it for the next steps

---

## Step 2: Configure SABnzbd (Usenet Downloader)

### 2.1 Access SABnzbd
Open: http://localhost:8081

### 2.2 Initial Setup Wizard
1. **Language**: Select your language
2. **Server Details**:
   - Host: `news.newsgroup.ninja`
   - Port: `563`
   - SSL: ✓ Yes
   - Username: `NEV4T9DL1PEA`
   - Password: `l0ngh0rn`
   - Connections: `30`
   - Test Server - should succeed
   
### 2.3 Configure Folders
Go to: **Settings → Folders**
- Temporary Download Folder: `/downloads/incomplete`
- Completed Download Folder: `/downloads/complete`
- Save

### 2.4 Configure Categories
Go to: **Settings → Categories**

Add these categories:

**tv:**
- Folder/Path: `tv`
- Processing: `Default`

**movies:**
- Folder/Path: `movies`
- Processing: `Default`

**music:**
- Folder/Path: `music`
- Processing: `Default`

Save changes.

### 2.5 Get SABnzbd API Key
1. Go to: **Settings → General → API Key**
2. Copy the API key
3. Save it for connecting to *arr apps

---

## Step 3: Connect Prowlarr to *arr Apps

### 3.1 Add Sonarr to Prowlarr
1. In Prowlarr: **Settings → Apps → Add Application**
2. Select: **Sonarr**
3. Configure:
   - Name: `Sonarr`
   - Prowlarr Server: `http://localhost:9696`
   - Sonarr Server: `http://gluetun:8989` (uses Gluetun network)
   - API Key: Get from Sonarr (Settings → General → API Key)
   - Test and Save

### 3.2 Add Radarr to Prowlarr
1. In Prowlarr: **Settings → Apps → Add Application**
2. Select: **Radarr**
3. Configure:
   - Name: `Radarr`
   - Prowlarr Server: `http://localhost:9696`
   - Radarr Server: `http://gluetun:7878`
   - API Key: Get from Radarr (Settings → General → API Key)
   - Test and Save

### 3.3 Add Lidarr to Prowlarr
1. In Prowlarr: **Settings → Apps → Add Application**
2. Select: **Lidarr**
3. Configure:
   - Name: `Lidarr`
   - Prowlarr Server: `http://localhost:9696`
   - Lidarr Server: `http://gluetun:8686`
   - API Key: Get from Lidarr (Settings → General → API Key)
   - Test and Save

**Note**: Prowlarr will automatically sync all indexers to these apps!

---

## Step 4: Configure Download Client in *arr Apps

### 4.1 Configure Sonarr
1. Open: http://localhost:8989
2. Go to: **Settings → Download Clients → Add**
3. Select: **SABnzbd**
4. Configure:
   - Name: `SABnzbd`
   - Host: `gluetun` (shares network)
   - Port: `8080`
   - API Key: (SABnzbd API key from Step 2.5)
   - Category: `tv`
   - Test and Save

5. **Configure Root Folder**:
   - Settings → Media Management → Root Folders
   - Add: `/tv`

### 4.2 Configure Radarr
1. Open: http://localhost:7878
2. Go to: **Settings → Download Clients → Add**
3. Select: **SABnzbd**
4. Configure:
   - Name: `SABnzbd`
   - Host: `gluetun`
   - Port: `8080`
   - API Key: (SABnzbd API key)
   - Category: `movies`
   - Test and Save

5. **Configure Root Folder**:
   - Settings → Media Management → Root Folders
   - Add: `/movies`

### 4.3 Configure Lidarr
1. Open: http://localhost:8686
2. Go to: **Settings → Download Clients → Add**
3. Select: **SABnzbd**
4. Configure:
   - Name: `SABnzbd`
   - Host: `gluetun`
   - Port: `8080`
   - API Key: (SABnzbd API key)
   - Category: `music`
   - Test and Save

5. **Configure Root Folder**:
   - Settings → Media Management → Root Folders
   - Add: `/music`

---

## Step 5: Configure Recyclarr (Quality Profiles)

### 5.1 Update .env with API Keys
Edit: `/home/joe/Parachini-HomeLab/.env`

Add these lines (replace with actual API keys):
```
SONARR_API_KEY=your_sonarr_api_key_here
RADARR_API_KEY=your_radarr_api_key_here
LIDARR_API_KEY=your_lidarr_api_key_here
```

### 5.2 Run Recyclarr Sync
```bash
cd /home/joe/Parachini-HomeLab
docker-compose run --rm recyclarr sync
```

This will:
- Apply TRaSH guides quality definitions
- Create custom formats
- Set up quality profiles

### 5.3 Verify in *arr Apps
1. Check Sonarr: **Settings → Profiles**
2. Check Radarr: **Settings → Profiles**
3. Should see quality profiles configured

---

## Step 6: Configure Jellyfin

### 6.1 Initial Setup
1. Open: http://localhost:8096
2. Complete setup wizard:
   - Language
   - Create admin account
   - Add media libraries:

**TV Shows:**
- Content type: Shows
- Folder: `/data/tv`
- Library name: TV Shows

**Movies:**
- Content type: Movies
- Folder: `/data/movies`
- Library name: Movies

**Music:**
- Content type: Music
- Folder: `/data/music`
- Library name: Music

3. Configure metadata downloaders (TMDb recommended)
4. Finish setup

---

## Step 7: Configure Overseerr

### 7.1 Initial Setup
1. Open: http://localhost:5055
2. Sign in with Plex or create local account
3. **Connect to Sonarr**:
   - Server: `http://sonarr:8989`
   - API Key: (Sonarr API key)
   - Default quality profile: HD-1080p
   - Root folder: `/tv`
   - Test and Save

4. **Connect to Radarr**:
   - Server: `http://radarr:7878`
   - API Key: (Radarr API key)
   - Default quality profile: HD-1080p
   - Root folder: `/movies`
   - Test and Save

5. Configure permissions and user access

---

## Verification Checklist

After completing all steps, verify:

- [ ] Prowlarr shows indexers with green status
- [ ] Prowlarr Apps tab shows Sonarr/Radarr/Lidarr connected
- [ ] SABnzbd can download (test with a small NZB)
- [ ] Sonarr can search for a TV show
- [ ] Radarr can search for a movie
- [ ] Recyclarr sync completed without errors
- [ ] Jellyfin shows media libraries
- [ ] Overseerr can request content

---

## Test the Complete Workflow

1. **In Overseerr**: Request a TV show or movie
2. **In Sonarr/Radarr**: Verify request appears
3. **In SABnzbd**: Watch download progress
4. **In Sonarr/Radarr**: File should import to media folder
5. **In Jellyfin**: Content should appear after library scan

---

## Troubleshooting

### Can't connect services
- Verify all containers running: `docker ps`
- Check logs: `docker logs <container_name>`
- Ensure using correct hostnames (gluetun for VPN services)

### Indexers not working
- Verify VPN is active: `docker exec gluetun wget -qO- ifconfig.me`
- Check indexer status in Prowlarr
- Verify indexer API keys are valid

### Downloads not starting
- Check SABnzbd has active server
- Verify *arr apps connected to SABnzbd
- Check categories configured correctly

### Files not importing
- Check folder permissions on NAS
- Verify root folders configured in *arr apps
- Check Media Management settings
