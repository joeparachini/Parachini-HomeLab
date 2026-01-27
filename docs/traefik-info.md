# Traefik - Reverse Proxy (Currently Disabled)

## Status
Traefik is **configured but not running** to save resources.

## What Traefik Does
- Provides domain-based routing (e.g., `sonarr.homelab.local`)
- SSL/HTTPS support with Let's Encrypt
- Single entry point for all services
- Automatic service discovery

## Why It's Disabled
- Currently accessing services directly via ports (simpler)
- Homepage dashboard provides unified access
- Not needed for local-only access
- Saves ~50MB RAM

## When to Enable Traefik

Enable if you want to:
- Access services via custom domains
- Set up external/remote access
- Add SSL certificates
- Have a more "production" setup

## How to Re-Enable

### 1. Uncomment in docker-compose.yml
Edit `/home/joe/Parachini-HomeLab/docker-compose.yml`:

Find the Traefik section (lines 4-29) and remove all the `#` comment symbols.

Change from:
```yaml
  # traefik:
  #   image: traefik:v2.11
```

To:
```yaml
  traefik:
    image: traefik:v2.11
```

### 2. Start Traefik
```bash
cd /home/joe/Parachini-HomeLab
docker-compose up -d traefik
```

### 3. Access Dashboard
- Dashboard: http://localhost:8080

## Configuration Files

All Traefik config is preserved in:
- `/home/joe/Parachini-HomeLab/config/traefik/traefik.yml` - Main config
- `/home/joe/Parachini-HomeLab/config/traefik/config.yml` - Dynamic routing
- `/home/joe/Parachini-HomeLab/config/traefik/acme.json` - SSL certificates

## Setting Up Domain Names (If Enabled)

### Option A: Local DNS (Easiest)
Edit `/etc/hosts` on your client machines:
```
192.168.1.YOUR_SERVER_IP  sonarr.homelab.local
192.168.1.YOUR_SERVER_IP  radarr.homelab.local
192.168.1.YOUR_SERVER_IP  jellyfin.homelab.local
```

### Option B: Router DNS
Configure custom DNS entries in your router pointing `*.homelab.local` to your server IP.

### Option C: Real Domain
Use a real domain with Cloudflare or other DNS provider for external access.

## Example Traefik Labels (For Services)

If you enable Traefik, add these labels to services in docker-compose.yml:

```yaml
jellyfin:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.jellyfin.rule=Host(`jellyfin.homelab.local`)"
    - "traefik.http.routers.jellyfin.entrypoints=http"
    - "traefik.http.services.jellyfin.loadbalancer.server.port=8096"
```

## Current Setup Without Traefik

All services accessed directly:
- Sonarr: http://localhost:8989
- Radarr: http://localhost:7878
- Jellyfin: http://localhost:8096
- Homepage: http://localhost:3000 (your main dashboard)

This works perfectly fine for local access!

## Related Documentation
- `quick-reference.md` - All service URLs
- `COMPLETE.md` - Full system overview
