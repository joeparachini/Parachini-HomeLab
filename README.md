# Parachini HomeLab - Docker Media Server

A portable Docker-based media server stack featuring the *arr suite, Usenet downloads, VPN protection, and automated quality management.

## 🚀 Features

- **Media Management**: Sonarr, Radarr, Lidarr (*arr stack)
- **Downloads**: SABnzbd (Usenet) via Surfshark VPN
- **Indexer Management**: Prowlarr for centralized indexer configuration
- **Quality Profiles**: Recyclarr for automated TRaSH guide implementation
- **Media Servers**: Jellyfin (+ Windows Plex integration)
- **Request Management**: Overseerr/Jellyseerr
- **Reverse Proxy**: Traefik with optional SSL
- **VPN Protection**: All download traffic routed through Gluetun + Surfshark

## 📁 Directory Structure

```
Parachini-HomeLab/
├── docker-compose.yml          # Main orchestration file
├── .env                        # Environment variables (not in git)
├── .env.example                # Template for .env
├── .gitignore                  # Excludes sensitive data
├── README.md                   # This file
├── config/                     # Application configurations
│   ├── traefik/
│   ├── gluetun/
│   ├── prowlarr/
│   ├── sonarr/
│   ├── radarr/
│   ├── lidarr/
│   ├── recyclarr/
│   ├── sabnzbd/
│   ├── jellyfin/
│   └── overseerr/
├── data/                       # Application data
│   └── downloads/              # Temporary download location
├── scripts/                    # Helper scripts
└── docs/                       # Additional documentation
```

## 🛠️ Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Surfshark VPN account
- Usenet provider account
- Usenet indexer accounts (e.g., NZBGeek, NZBFinder)

### Initial Setup

1. **Clone and configure**:
   ```bash
   cd Parachini-HomeLab
   cp .env.example .env
   nano .env  # Edit with your settings
   ```

2. **Key settings to update in `.env`**:
   - `MEDIA_PATH` - Path to your media library (shared with Windows Plex)
   - `WIREGUARD_PRIVATE_KEY` - From Surfshark dashboard
   - `WIREGUARD_ADDRESSES` - From Surfshark dashboard
   - Usenet provider credentials
   - `TZ` - Your timezone

3. **Get your user/group IDs**:
   ```bash
   id
   # Update PUID and PGID in .env if different from 1000
   ```

4. **Start Traefik** (Phase 1):
   ```bash
   docker-compose up -d traefik
   ```

5. **Access Traefik dashboard**:
   - Open: http://localhost:8080
   - Verify Traefik is running

## 🌐 Service URLs

Once fully deployed, services will be available at:

| Service | URL | Description |
|---------|-----|-------------|
| Traefik | http://localhost:8080 | Reverse proxy dashboard |
| Prowlarr | http://localhost:9696 | Indexer manager |
| Sonarr | http://localhost:8989 | TV shows |
| Radarr | http://localhost:7878 | Movies |
| Lidarr | http://localhost:8686 | Music |
| SABnzbd | http://localhost:8081 | Usenet downloader |
| Jellyfin | http://localhost:8096 | Media server |
| Overseerr | http://localhost:5055 | Request management |

*Note: Services behind VPN (Prowlarr, SABnzbd, *arr apps) will be accessible via Gluetun's exposed ports*

## 🔒 VPN Architecture

All download-related services route through Gluetun VPN container:
- **Protected**: SABnzbd, Prowlarr, Sonarr, Radarr, Lidarr
- **Direct**: Traefik, Jellyfin, Overseerr (no VPN needed)
- **Kill Switch**: Built into Gluetun - no leaks if VPN drops

## 🔄 Recyclarr

Automatically syncs quality profiles and custom formats from TRaSH guides:
- Run manually: `docker-compose run --rm recyclarr sync`
- Configure in: `config/recyclarr/recyclarr.yml`

## 🪟 Windows Plex Integration

The `MEDIA_PATH` should point to a location accessible by both:
1. This Docker stack (for *arr apps to organize media)
2. Your Windows Plex server (via network share or dual-mounted drive)

Example setup:
- Docker stack: `/mnt/media` (Linux mount)
- Windows Plex: `\\server\media` (SMB share to same location)

## 📦 Deployment Phases

- ✅ **Phase 1**: Foundation (Traefik, directory structure)
- ⏳ **Phase 2**: VPN & Download Stack (Gluetun, SABnzbd, Prowlarr)
- ⏳ **Phase 3**: *arr Stack (Sonarr, Radarr, Lidarr, Recyclarr)
- ⏳ **Phase 4**: Media Servers (Jellyfin, Overseerr)
- ⏳ **Phase 5**: Configuration & Integration
- ⏳ **Phase 6**: Optional Enhancements
- ⏳ **Phase 7**: Documentation & Testing

## 🔧 Common Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f [service_name]

# Restart a service
docker-compose restart [service_name]

# Update all containers
docker-compose pull && docker-compose up -d

# Check VPN connection
docker exec gluetun wget -qO- ifconfig.me
```

## 🚚 Migration/Portability

To move this stack to a new host:

1. Copy entire `Parachini-HomeLab` directory
2. Copy media library (or update `MEDIA_PATH` in .env)
3. Update `.env` if paths changed
4. Run `docker-compose up -d`

All configuration is preserved in the `config/` directory.

## 📝 License

Personal homelab project - free to use and modify.

## 🙏 Credits

- [TRaSH Guides](https://trash-guides.info/) - Quality profiles
- [Recyclarr](https://github.com/recyclarr/recyclarr) - Automation
- [Gluetun](https://github.com/qdm12/gluetun) - VPN client
