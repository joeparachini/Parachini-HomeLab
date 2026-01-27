# VPN Removal - Complete Success! 🎉

## Date: 2026-01-27

## Decision Made
Removed VPN routing from all Usenet services while keeping Gluetun available for potential future torrenting.

## Reasoning

### Why Usenet Doesn't Need VPN:
1. **Client-Server Architecture** - Not P2P like torrents
2. **SSL Encryption** - All traffic encrypted (port 563)
3. **No Public IP Exposure** - Only visible to Usenet provider
4. **Copyright Monitoring Difficult** - No public swarm to join
5. **Speed Cost** - VPN limited to 14-20 MB/s vs 40-60 MB/s direct

### Torrents vs Usenet Privacy:
| Factor | Torrents | Usenet |
|--------|----------|--------|
| Architecture | P2P (public swarm) | Client-Server |
| IP Visibility | PUBLIC to everyone | Only to provider |
| Encryption | Optional | SSL (port 563) |
| Monitoring | Easy (join swarm) | Very difficult |
| VPN Necessity | **ESSENTIAL** | Optional |
| Legal Risk History | Millions of DMCA | Very rare |

## Changes Made

### 1. Docker Compose Updates
**Services moved from VPN to direct networking:**
- SABnzbd: `network_mode: service:gluetun` → `ports: 8081:8080` + `networks: proxy`
- Prowlarr: Same change
- Sonarr: Same change
- Radarr: Same change
- Lidarr: Same change

**Gluetun:**
- Still running (ready for torrents)
- Removed port mappings (services have own ports now)
- Available at 8888 (HTTP proxy), 8388 (Shadowsocks)

### 2. Configuration Updates
**Recyclarr** (`config/recyclarr/recyclarr.yml`):
- Sonarr: `http://172.18.0.3:8989` → `http://sonarr:8989`
- Radarr: `http://172.18.0.3:7878` → `http://radarr:7878`

**SABnzbd** (`config/sabnzbd/sabnzbd.ini`):
- `host_whitelist`: `84bb1f03ea9d` → `sabnzbd`
- Required to allow container hostname access (fixed 403 Forbidden)

**Homepage** (`config/homepage/services.yaml`):
- Sonarr widget: `172.18.0.3:8989` → `sonarr:8989`
- Radarr widget: `172.18.0.3:7878` → `radarr:7878`
- Prowlarr widget: `172.18.0.3:9696` → `prowlarr:9696`
- SABnzbd widget: `172.18.0.3:8080` → `sabnzbd:8080`
- Removed Gluetun card

**Download Client Settings** (via UI in each *arr app):
- Sonarr → Settings → Download Clients → SABnzbd: Host `localhost` → `sabnzbd`
- Radarr → Settings → Download Clients → SABnzbd: Host `localhost` → `sabnzbd`
- Lidarr → Settings → Download Clients → SABnzbd: Host `localhost` → `sabnzbd`

### 3. Networking Changes
**Before:**
```
All services in Gluetun's network namespace
→ Communicated via localhost
→ Shared VPN connection
```

**After:**
```
Each service on 'proxy' Docker network
→ Communicate via container hostnames
→ Docker DNS resolution
→ Direct internet connection with SSL
```

## Performance Results

### Speed Test Results:
| Scenario | Speed | Notes |
|----------|-------|-------|
| With VPN (initial) | 13-16 MB/s | Baseline |
| With VPN (slow server) | 8 MB/s | Bad lottery pick |
| With VPN (filtered cities) | 14-20 MB/s | After optimization |
| **Without VPN (direct SSL)** | **40-60 MB/s** | **3-4x improvement!** |

### Bottleneck Analysis:
1. ❌ ~~Local disk~~ - Tested slower (WSL2 overhead)
2. ❌ ~~NAS write speed~~ - Not the issue
3. ❌ ~~Connection count~~ - 50 was slower than 30
4. ✅ **VPN was the bottleneck** - Confirmed!

## Issues Encountered & Solutions

### Issue 1: Services Can't Connect to Each Other
**Problem:** After removing `network_mode: service:gluetun`, services couldn't reach each other.
**Cause:** Still configured to use `localhost` instead of container hostnames.
**Solution:** Updated all configs to use container names (`sabnzbd`, `sonarr`, etc.)

### Issue 2: 403 Forbidden from SABnzbd
**Problem:** *arr apps got `403 Forbidden` when connecting to SABnzbd.
**Cause:** SABnzbd's `host_whitelist` only had old container ID (`84bb1f03ea9d`).
**Solution:** Updated whitelist to include `sabnzbd` hostname.

### Issue 3: Homepage Widgets Not Working
**Problem:** Dashboard couldn't fetch stats from services.
**Cause:** Widget URLs still pointing to Gluetun IP (`172.18.0.3`).
**Solution:** Updated all widget URLs to use container hostnames.

## Current Architecture

### Network Topology:
```
Internet
  ↓ (SSL Port 563)
SABnzbd (sabnzbd:8080)
  ↓ (Docker network: proxy)
Sonarr/Radarr/Lidarr
  ↓ (Docker network: proxy)
NAS (/mnt/nas/media)
  ↓ (SMB/NFS)
Plex (Windows)
```

### Docker Network (proxy):
- SABnzbd: 8081:8080
- Prowlarr: 9696:9696
- Sonarr: 8989:8989
- Radarr: 7878:7878
- Lidarr: 8686:8686
- Recyclarr: (no ports)
- Homepage: 3000:3000
- Jellyfin: 8096:8096
- Overseerr: 5055:5055
- Bazarr: 6767:6767
- Gluetun: 8888:8888, 8388:8388 (ready for torrents)

## Security Posture

### Current Protection:
✅ **SSL/TLS Encryption** - All Usenet traffic encrypted (port 563)  
✅ **Client-Server** - No P2P swarm, no public IP exposure  
✅ **Usenet Provider** - Only party that sees your activity  
✅ **VPN Available** - Gluetun ready if torrenting is added  

### What ISP Can See:
⚠️ **Connection to Usenet server** - ISP can see you connect to news.newsgroup.ninja  
✅ **Traffic is encrypted** - Cannot see what files you download  
✅ **No copyright monitoring** - No public participation like torrents  

### Risk Assessment:
- **Torrents without VPN:** 🔴 HIGH RISK (public IP, easy monitoring)
- **Usenet without VPN:** 🟢 LOW RISK (private, encrypted, no swarm)
- **Usenet with VPN:** 🟢 LOWEST RISK (but speed penalty)

## Backup & Recovery

### VPN Configuration Preserved:
- **File:** `docker-compose.yml.vpn-backup`
- **Contains:** Full VPN routing configuration
- **Gluetun:** Still running, just not routing Usenet traffic

### To Re-Enable VPN:
1. Stop services: `docker-compose down`
2. Restore backup: `cp docker-compose.yml.vpn-backup docker-compose.yml`
3. Revert SABnzbd whitelist: `84bb1f03ea9d`
4. Revert *arr download clients: `localhost`
5. Revert Recyclarr: `172.18.0.3:port`
6. Revert Homepage: `172.18.0.3:port`
7. Start services: `docker-compose up -d`

## Lessons Learned

### What We Discovered:
1. **VPN server lottery is real** - US servers varied 2.6-17.7 MB/s (6.8x!)
2. **City filtering helps** - Limiting to major cities reduced variance
3. **Usenet ≠ Torrents** - Different privacy model, different requirements
4. **Docker networking** - Shared network namespace vs individual containers
5. **SABnzbd security** - Host whitelist blocks non-approved hostnames
6. **Speed isn't everything** - But 3-4x improvement is worth it!

### Best Practices Established:
- Always backup configs before major changes
- Test one variable at a time (A/B testing)
- Document networking changes thoroughly
- Understand the privacy model of protocols
- Balance security with performance

## Future Considerations

### If Adding Torrents:
1. Create separate torrent download client (qBittorrent, Transmission)
2. Route through Gluetun: `network_mode: service:gluetun`
3. Add port mapping to Gluetun container
4. **DO NOT** bypass VPN for torrents!

### Monitoring:
- Watch for ISP throttling of Usenet connections
- Monitor download speeds over time
- Check for any legal notices (unlikely but possible)
- Re-evaluate if situation changes

## Final Status

### System Health: ✅ EXCELLENT
- All 11 containers running
- All services communicating properly
- Download speeds 3-4x faster
- Automated backups functioning
- Dashboard showing live stats

### User Satisfaction: 🎉
"yep everything is working nice and fast"

### Project Status: ✅ COMPLETE

---

## Quick Reference

### Service URLs:
- SABnzbd: http://localhost:8081
- Prowlarr: http://localhost:9696
- Sonarr: http://localhost:8989
- Radarr: http://localhost:7878
- Lidarr: http://localhost:8686
- Jellyfin: http://localhost:8096
- Overseerr: http://localhost:5055
- Bazarr: http://localhost:6767
- Homepage: http://localhost:3000

### Key Files Modified:
- `/home/joe/Parachini-HomeLab/docker-compose.yml` (VPN routing removed)
- `/home/joe/Parachini-HomeLab/config/sabnzbd/sabnzbd.ini` (whitelist)
- `/home/joe/Parachini-HomeLab/config/recyclarr/recyclarr.yml` (hostnames)
- `/home/joe/Parachini-HomeLab/config/homepage/services.yaml` (hostnames)
- Download client settings in Sonarr/Radarr/Lidarr (via UI)

### Backup File:
- `/home/joe/Parachini-HomeLab/docker-compose.yml.vpn-backup`

---

**Implementation Date:** 2026-01-27  
**Final Speed:** 40-60 MB/s (3-4x improvement)  
**Status:** Production, Fully Operational ✅
