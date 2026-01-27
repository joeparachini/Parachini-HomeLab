# Windows Plex Integration Guide

## Overview
Your Synology NAS media folders are accessible by both:
1. This Docker homelab stack (Linux paths)
2. Your Windows Plex server (SMB/Network paths)

## Media Location Mapping

| Content | Docker Path | Windows Plex Path |
|---------|-------------|-------------------|
| TV Shows | `/mnt/nas/media/tv` | `\\192.168.1.128\Parachini-Storage\media\tv` |
| Movies | `/mnt/nas/media/movies` | `\\192.168.1.128\Parachini-Storage\media\movies` |
| Music | `/mnt/nas/media/music` | `\\192.168.1.128\Parachini-Storage\media\music` |

## Setting Up Plex on Windows

### Step 1: Map Network Drive (Recommended)
This makes accessing the NAS easier:

1. Open File Explorer on Windows
2. Right-click "This PC" → "Map network drive"
3. Choose drive letter: **Z:** (or your preference)
4. Folder: `\\192.168.1.128\Parachini-Storage`
5. Check "Reconnect at sign-in"
6. Enter credentials if prompted
7. Click Finish

Now your media is at:
- `Z:\media\tv`
- `Z:\media\movies`
- `Z:\media\music`

### Step 2: Add Libraries to Plex

1. Open Plex Web UI on your Windows machine
2. Settings → Manage → Libraries
3. Add Library:

**TV Shows:**
- Type: TV Shows
- Add folder: `Z:\media\tv` (or `\\192.168.1.128\Parachini-Storage\media\tv`)
- Scanner: Plex Series Scanner
- Agent: The Movie Database

**Movies:**
- Type: Movies
- Add folder: `Z:\media\movies`
- Scanner: Plex Movie Scanner
- Agent: The Movie Database

**Music:**
- Type: Music
- Add folder: `Z:\media\music`
- Scanner: Plex Music Scanner
- Agent: Last.fm or Plex Music

### Step 3: Configure Sonarr/Radarr

When you configure Sonarr and Radarr, they will automatically:
1. Monitor for new episodes/movies
2. Download via SABnzbd
3. Move completed files to the media folders
4. Plex will automatically detect and add them

**Important:** Use the same folder structure in your *arr apps:
- Sonarr: `/tv` → maps to `/mnt/nas/media/tv`
- Radarr: `/movies` → maps to `/mnt/nas/media/movies`
- Lidarr: `/music` → maps to `/mnt/nas/media/music`

## Workflow

```
1. Request made in Overseerr
           ↓
2. Sonarr/Radarr receives request
           ↓
3. Prowlarr searches indexers
           ↓
4. SABnzbd downloads via VPN
           ↓
5. Files moved to NAS media folders
           ↓
6. Both Jellyfin AND Windows Plex detect new content
```

## Troubleshooting

### Windows Can't Access NAS
1. Ensure SMB is enabled on Synology:
   - Control Panel → File Services → SMB → Enable
2. Check Windows can ping NAS: `ping 192.168.1.128`
3. Try accessing directly: `\\192.168.1.128` in File Explorer

### Plex Not Seeing New Files
1. Check folder permissions on NAS
2. Ensure Plex has access to the network share
3. Try manual library scan in Plex
4. Check Plex service is running as correct user

### File Permission Issues
On your Docker host, files are created with PUID=1000, PGID=1000
Ensure your NAS allows these IDs to write, or adjust Synology permissions:
- Control Panel → Shared Folder → Parachini-Storage → Edit → Permissions

## Performance Tips

1. **Use Wired Connection:** Both NAS and Plex server should be wired to network
2. **Plex Transcoding:** Enable hardware transcoding if your server supports it
3. **Direct Play:** Configure Plex clients to Direct Play when possible (no transcoding)
4. **NAS Performance:** Keep NAS resource usage under 80%

## Dual Server Benefits

Running both Jellyfin (Docker) and Plex (Windows) gives you:
- ✅ **Redundancy:** If one server fails, the other works
- ✅ **Compatibility:** Jellyfin for open-source fans, Plex for best client apps
- ✅ **Testing:** Try new features in Jellyfin without affecting main Plex
- ✅ **Remote Access:** Use Plex for easy external access, Jellyfin for local

Both servers read from the same NAS media library - organized by Sonarr/Radarr!
