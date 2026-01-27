# Quick Reference - Service URLs and Access

## All Services

| Service | URL | Default User | Purpose |
|---------|-----|--------------|---------|
| **Traefik** | http://localhost:8080 | None | Reverse proxy dashboard |
| **SABnzbd** | http://localhost:8081 | Setup on first visit | Usenet downloads |
| **Jellyfin** | http://localhost:8096 | Setup on first visit | Media streaming |
| **Overseerr** | http://localhost:5055 | Setup on first visit | Request management |
| **Prowlarr** | http://localhost:9696 | Setup on first visit | Indexer manager |
| **Sonarr** | http://localhost:8989 | Setup on first visit | TV automation |
| **Radarr** | http://localhost:7878 | Setup on first visit | Movie automation |
| **Lidarr** | http://localhost:8686 | Setup on first visit | Music automation |

## Configuration Order (Follow this sequence!)

1. **SABnzbd** (http://localhost:8081)
   - Configure Usenet server
   - Get API key
   - Set up categories

2. **Prowlarr** (http://localhost:9696)
   - Add indexers
   - Get API key

3. **Sonarr** (http://localhost:8989)
   - Get API key
   - Add to Prowlarr
   - Add SABnzbd as download client
   - Set root folder: `/tv`

4. **Radarr** (http://localhost:7878)
   - Get API key
   - Add to Prowlarr
   - Add SABnzbd as download client
   - Set root folder: `/movies`

5. **Lidarr** (http://localhost:8686)
   - Get API key
   - Add to Prowlarr
   - Add SABnzbd as download client
   - Set root folder: `/music`

6. **Update .env** with API keys
   ```bash
   nano /home/joe/Parachini-HomeLab/.env
   ```
   Add:
   ```
   SONARR_API_KEY=...
   RADARR_API_KEY=...
   LIDARR_API_KEY=...
   ```

7. **Run Recyclarr**
   ```bash
   cd /home/joe/Parachini-HomeLab
   docker-compose run --rm recyclarr sync
   ```

8. **Jellyfin** (http://localhost:8096)
   - Create admin account
   - Add media libraries

9. **Overseerr** (http://localhost:5055)
   - Connect to Sonarr
   - Connect to Radarr

## Important Hostnames for Configuration

When configuring services that talk to each other:

- **Services through VPN** (SABnzbd, Prowlarr, Sonarr, Radarr, Lidarr) use: `gluetun`
  - Example: `http://gluetun:8080` for SABnzbd
  
- **Services NOT through VPN** (Jellyfin, Overseerr) use actual container names:
  - `http://sonarr:8989`
  - `http://radarr:7878`
  - `http://jellyfin:8096`

## Quick Commands

```bash
# View all running containers
docker ps

# View logs for a service
docker logs <service_name>
docker logs -f <service_name>  # Follow logs

# Restart a service
docker-compose restart <service_name>

# Restart all services
docker-compose restart

# Stop all services
docker-compose down

# Start all services
docker-compose up -d

# Run Recyclarr sync
docker-compose run --rm recyclarr sync

# Check VPN IP
docker exec gluetun wget -qO- ifconfig.me

# View NAS contents
ls -la /mnt/nas/media/
```

## Credentials Reference

**Usenet:**
- Host: news.newsgroup.ninja
- Port: 563 (SSL)
- User: NEV4T9DL1PEA
- Pass: l0ngh0rn
- Connections: 30

**VPN:**
- Provider: Surfshark
- Type: WireGuard
- Location: United States

**NAS:**
- IP: 192.168.1.128
- Share: /volume1/Parachini-Storage
- Mount: /mnt/nas

## Folder Structure

```
/mnt/nas/
├── downloads/           # Temporary downloads
│   ├── incomplete/      # Active downloads
│   └── complete/        # Finished downloads
│       ├── tv/
│       ├── movies/
│       └── music/
└── media/              # Final organized media
    ├── tv/             # Sonarr managed
    ├── movies/         # Radarr managed
    └── music/          # Lidarr managed
```

## Need Help?

- **Full guide**: `/home/joe/Parachini-HomeLab/docs/configuration-guide.md`
- **Plex integration**: `/home/joe/Parachini-HomeLab/docs/windows-plex-integration.md`
- **Check logs**: `docker logs <service>`
