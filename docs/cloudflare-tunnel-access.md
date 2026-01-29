# Cloudflare Tunnel - Access Guide

## 🌐 Your Services Are Now Live!

All services are accessible remotely via Cloudflare Tunnel with automatic SSL certificates and Google OAuth protection.

### Service URLs

| Service | URL | Authentication |
|---------|-----|----------------|
| 📊 Dashboard | https://dashboard.joeparachini.com | 🔒 Google OAuth |
| 🎬 Jellyfin | https://jellyfin.joeparachini.com | ✅ Public (Native Auth) |
| 📺 Plex | https://plex.joeparachini.com | ✅ Public (Native Auth) |
| 📺 Overseerr | https://overseerr.joeparachini.com | 🔒 Google OAuth |
| 📺 Sonarr | https://sonarr.joeparachini.com | 🔒 Google OAuth |
| 🎬 Radarr | https://radarr.joeparachini.com | 🔒 Google OAuth |
| 🎵 Lidarr | https://lidarr.joeparachini.com | 🔒 Google OAuth |
| 🔍 Prowlarr | https://prowlarr.joeparachini.com | 🔒 Google OAuth |
| 📥 SABnzbd | https://sabnzbd.joeparachini.com | 🔒 Google OAuth |
| 💬 Bazarr | https://bazarr.joeparachini.com | 🔒 Google OAuth |

**🔒 Google OAuth** = Requires login with joeparachini@gmail.com  
**✅ Public** = Direct access with service's native authentication

### Architecture

```
Internet Users
      ↓
Cloudflare Edge Network (SSL, DDoS Protection, Caching)
      ↓
Cloudflare Tunnel (Encrypted Connection)
      ↓
cloudflared Container (Your Home)
      ↓
Docker Services (proxy network)
```

### Key Benefits

✅ **No Port Forwarding** - No open ports on your router  
✅ **Hidden IP** - Your home IP address is completely hidden  
✅ **Free SSL** - Automatic HTTPS with Cloudflare certificates  
✅ **DDoS Protection** - Protected by Cloudflare's network  
✅ **Google OAuth** - Single sign-on for all admin services  
✅ **Zero Trust** - Centralized access control via Cloudflare Access

### Security Status

🔒 **Admin services protected with Google OAuth:**
- Dashboard, Overseerr, *arr apps (Sonarr/Radarr/Lidarr), Prowlarr, SABnzbd, Bazarr
- Only joeparachini@gmail.com can access
- 24-hour session duration

✅ **Media services remain public (bypass OAuth):**
- Jellyfin & Plex use their native authentication
- Mobile apps and TV apps work without issues
- Casting and remote playback fully functional

### Local Access

Local network access still works on original ports:
- Dashboard: http://localhost:3000
- Jellyfin: http://localhost:8096
- Overseerr: http://localhost:5055
- Sonarr: http://localhost:8989
- Radarr: http://localhost:7878
- Lidarr: http://localhost:8686
- Prowlarr: http://localhost:9696
- SABnzbd: http://localhost:8081
- Bazarr: http://localhost:6767
- Plex: http://192.168.1.136:32400

### Tunnel Status Commands

```bash
# Check tunnel container status
docker ps -f name=cloudflared

# View tunnel logs
docker logs cloudflared --tail 50

# Restart tunnel
docker-compose restart cloudflared

# Check tunnel connectivity
curl -sI https://dashboard.joeparachini.com | grep -E "HTTP|cf-ray"

# View all services status
docker-compose ps
```

### Troubleshooting

**Service returns 503:**
- Check if the service container is running: `docker ps`
- Verify tunnel is connected: `docker logs cloudflared`
- Check Zero Trust dashboard for tunnel status

**Hostname validation errors (Homepage/SABnzbd):**
- Homepage: Set `HOMEPAGE_ALLOWED_HOSTS` env var in docker-compose.yml
- SABnzbd: Add domain to `host_whitelist` in sabnzbd.ini

**Google OAuth not working:**
- Verify Google OAuth app redirect URI: `https://joeparachini.cloudflareaccess.com/cdn-cgi/access/callback`
- Check Cloudflare Access policies in Zero Trust dashboard
- Ensure email is in the allowed list

**DNS not resolving:**
- DNS records managed by Cloudflare Zero Trust (not main DNS)
- Changes propagate within 1-2 minutes
- Check: https://one.dash.cloudflare.com/ → Access → Tunnels

**Tunnel disconnected:**
- Tunnel automatically reconnects on container restart
- Check logs: `docker logs cloudflared`
- Restart if needed: `docker-compose restart cloudflared`

### Configuration Files

**Modified files:**
- `docker-compose.yml` - Added cloudflared service, updated homepage env vars
- `.env` - Added Cloudflare tunnel token and API credentials
- `config/sabnzbd/sabnzbd.ini` - Added hostname to whitelist
- `config/homepage/services.yaml` - Updated all URLs to HTTPS

**Scripts created:**
- `scripts/setup-cloudflare-dns.sh` - DNS record creation
- `scripts/cleanup-cloudflare-dns.sh` - DNS record cleanup

### What Changed

**Before:**
- Services only accessible on local network
- Would need port forwarding + dynamic DNS for remote access
- No SSL encryption
- Home IP exposed
- No centralized authentication

**After:**
- Services accessible from anywhere with clean URLs
- Zero exposed ports
- Automatic SSL/TLS encryption
- Home IP completely hidden
- Protected by Cloudflare's edge network
- Single sign-on with Google OAuth for admin tools
- Jellyfin/Plex remain mobile-app friendly

### Access Management

**To add more authorized users:**
1. Go to Cloudflare Zero Trust dashboard
2. Navigate to Access → Applications
3. Edit the application policy
4. Add additional email addresses to the "Allow" rule

**To adjust session duration:**
1. Edit the Access Application
2. Change "Session Duration" (default: 24 hours)
3. Save changes

**To remove access:**
1. Edit the Access Application policy
2. Remove the email from the allowed list
3. User will lose access on next session expiration

### Monitoring

**Cloudflare Zero Trust Dashboard:**
- View tunnel status: Access → Tunnels
- View access logs: Logs → Access requests
- Monitor authentication attempts
- See connected users

**Homepage Dashboard:**
- Central hub: https://dashboard.joeparachini.com
- Shows service status and metrics
- Direct links to all services

### Backup & Recovery

**Tunnel credentials stored in:**
- `.env` file: `CLOUDFLARE_TUNNEL_TOKEN`
- Cloudflare Zero Trust dashboard (always accessible)

**To restore tunnel on new system:**
1. Copy entire Parachini-HomeLab directory
2. Copy `.env` file with tunnel token
3. Run `docker-compose up -d cloudflared`
4. Tunnel automatically reconnects to same configuration

**Emergency access if tunnel fails:**
- All services still accessible locally
- No data loss - tunnel only affects external access
- Local ports remain open on LAN

---

**Setup Date:** 2026-01-29  
**Tunnel ID:** adfc2864-430d-47dc-9ef7-843738042e43  
**Tunnel Name:** parachini-homelab  
**Domain:** joeparachini.com  
**Authentication:** Google OAuth (joeparachini@gmail.com)  
**Protected Services:** 8 (Dashboard, Overseerr, Sonarr, Radarr, Lidarr, Prowlarr, SABnzbd, Bazarr)  
**Public Services:** 2 (Jellyfin, Plex)
