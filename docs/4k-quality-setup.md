# 4K (Ultra-HD) Quality Profile Setup

## Overview
The homelab is now configured to prioritize **4K (2160p)** content for both movies and TV shows.

## Configured Profiles

### Radarr - Ultra-HD (Movies)
**Custom Format Scores:**
- BR-DISK: -10000 (blocked)
- LQ: -10000 (blocked)
- 3D: -10000 (blocked)

**Quality Order:**
1. Bluray-2160p
2. WEBDL-2160p
3. WEBRip-2160p
4. HDTV-2160p

**Upgrade Strategy:**
- Upgrades allowed: Yes
- Upgrade until: Bluray-2160p
- Minimum format score: 0

### Sonarr - Ultra-HD (TV Shows)
**Custom Format Scores:**
- WEB Tier 01: +1700 (preferred)
- WEB Tier 02: +1650 (preferred)
- WEB Tier 03: +1600 (preferred)
- WEB Scene: +1600 (preferred)
- BR-DISK: -10000 (blocked)
- LQ: -10000 (blocked)
- x265 (HD): -10000 (blocked)

**Quality Order:**
1. HDTV-2160p
2. WEBRip-2160p
3. WEBDL-2160p
4. Bluray-2160p Remux
5. Bluray-2160p

**Upgrade Strategy:**
- Upgrades allowed: Yes
- Upgrade until: Bluray-2160p
- Minimum format score: 0

## How It Works

### Automated Quality Selection
When Sonarr or Radarr searches for content:
1. **Finds all available releases**
2. **Applies custom format scores** (boosts WEB releases, penalizes unwanted)
3. **Filters by quality profile** (only 4K/2160p)
4. **Selects highest-scoring release** that meets criteria
5. **Sends to SABnzbd** for download

### Blocked Formats
These formats are automatically rejected:
- **BR-DISK** - Unprocessed Blu-ray discs (huge, needs extraction)
- **LQ** - Low quality releases
- **3D** - 3D releases (not needed)
- **x265 (HD)** - x265 encoded HD (not 4K)

### Preferred Formats
These formats get priority:
- **WEB Tier 01-03** - High-quality web releases from top streaming services
- **Bluray-2160p** - Full quality Blu-ray rips
- **WEBDL-2160p** - Web downloads (untouched streams)

## File Size Expectations

### Movies (4K)
- Web-DL: 15-40GB
- Bluray Remux: 40-80GB
- Bluray Encode: 20-50GB

### TV Episodes (4K)
- 30min episode: 3-8GB
- 60min episode: 5-15GB
- Full season (10 episodes): 50-150GB

**Storage Recommendation:** Ensure you have sufficient space on your NAS. A 4K movie collection grows quickly!

## Overseerr Integration

Overseerr is configured to use Ultra-HD profiles by default:
- **Sonarr**: Ultra-HD profile for TV shows
- **Radarr**: Ultra-HD profile for movies

When users request content, it will automatically grab 4K versions.

## Recyclarr Configuration

The quality profiles are managed by Recyclarr using TRaSH guides:
- **Config location**: `config/recyclarr/recyclarr.yml`
- **Auto-sync**: Run `docker exec recyclarr recyclarr sync` to update
- **Base URLs**: Points to Sonarr/Radarr via Gluetun IP (172.18.0.3)

### Manual Sync Command
```bash
docker exec recyclarr recyclarr sync
```

## Switching Between HD and 4K

### Per-Request Basis (Overseerr)
When requesting content, users can choose the profile:
1. Make request in Overseerr
2. Select quality profile: HD-1080p or Ultra-HD
3. Submit

### Change Default Profile
To change the default profile in Overseerr:
1. Settings → Services → Sonarr/Radarr
2. Change "Quality Profile" dropdown
3. Save

### Manually in Sonarr/Radarr
When adding content directly:
1. Search for show/movie
2. Select profile: HD-1080p or Ultra-HD
3. Add

## Verification

### Check Profiles Are Applied
**Sonarr:**
```bash
curl -s -H "X-Api-Key: a01c4c83bb3644a3a9ef17c7089fd34f" \
  http://localhost:8989/api/v3/qualityprofile | grep -A 20 "Ultra-HD"
```

**Radarr:**
```bash
curl -s -H "X-Api-Key: 8dfd96b6135243c49d67aac68fe40c4a" \
  http://localhost:7878/api/v3/qualityprofile | grep -A 20 "Ultra-HD"
```

### Check Custom Format Scores
1. Open Sonarr/Radarr web interface
2. Settings → Profiles
3. Click on Ultra-HD profile
4. Scroll down to "Custom Formats" section
5. Verify scores are assigned

## Troubleshooting

### Downloads Grabbing HD Instead of 4K
- Verify profile is set to Ultra-HD in Sonarr/Radarr
- Check if 4K releases are available on your indexers
- Some content may not have 4K versions yet

### File Sizes Too Large
- Switch to HD-1080p profile for specific shows/movies
- Consider using x265 encodes (smaller but lower quality)
- Upgrade NAS storage

### Slow Streaming/Buffering
- 4K requires ~25-50 Mbps bandwidth
- Ensure Plex/Jellyfin can direct play (no transcoding)
- Check network speed between server and client

## Related Documentation
- `COMPLETE.md` - Full system overview
- `configuration-guide.md` - Initial setup guide
- `quick-reference.md` - Quick commands

## Last Updated
January 26, 2026 - Initial 4K configuration
