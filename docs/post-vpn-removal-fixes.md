# Post-VPN Removal Configuration Changes

## Issue
After removing VPN routing, *arr apps cannot connect to SABnzbd because they're still configured to use `localhost`.

## Why This Happened

### Before (with VPN):
```
network_mode: service:gluetun
```
All services (SABnzbd, Prowlarr, Sonarr, Radarr, Lidarr) shared Gluetun's network namespace.
- They could communicate via `localhost`
- All appeared as one host to each other

### After (without VPN):
```
networks:
  - proxy
```
Each service has its own container with its own network interface.
- Must use container hostnames (DNS)
- Docker's built-in DNS resolves container names

## Required Changes

Update the **Host** field in Download Client settings from `localhost` to `sabnzbd`:

### Sonarr
**URL:** http://localhost:8989

1. Go to Settings → Download Clients
2. Click on SABnzbd download client
3. Change:
   - **Host:** `localhost` → **`sabnzbd`**
   - **Port:** `8080` (no change)
   - **API Key:** (no change)
4. Click "Test" - should succeed
5. Save

### Radarr
**URL:** http://localhost:7878

1. Go to Settings → Download Clients
2. Click on SABnzbd download client
3. Change:
   - **Host:** `localhost` → **`sabnzbd`**
   - **Port:** `8080` (no change)
   - **API Key:** (no change)
4. Click "Test" - should succeed
5. Save

### Lidarr
**URL:** http://localhost:8686

1. Go to Settings → Download Clients
2. Click on SABnzbd download client
3. Change:
   - **Host:** `localhost` → **`sabnzbd`**
   - **Port:** `8080` (no change)
   - **API Key:** (no change)
4. Click "Test" - should succeed
5. Save

## Verification

After making changes:
1. Go to any *arr app → Activity
2. Search for and download a test item
3. Verify it appears in SABnzbd queue
4. Verify it imports back to *arr app after completion

## Technical Details

### Docker Networking
All services are on the `proxy` network:
```yaml
networks:
  - proxy
```

Docker automatically provides DNS resolution:
- `sabnzbd` → resolves to SABnzbd container IP
- `prowlarr` → resolves to Prowlarr container IP
- `sonarr` → resolves to Sonarr container IP
- etc.

### Port Mappings
Each service now exposes its own port:
- SABnzbd: `8081:8080` (host 8081 → container 8080)
- Prowlarr: `9696:9696`
- Sonarr: `8989:8989`
- Radarr: `7878:7878`
- Lidarr: `8686:8686`

**Note:** Internal container communication uses internal ports (8080, 9696, etc.), not the host-mapped ports.

## Other Inter-Service Communication

Already updated:
- ✅ **Recyclarr** → Changed from `172.18.0.3:8989` to `sonarr:8989`
- ✅ **Recyclarr** → Changed from `172.18.0.3:7878` to `radarr:7878`

Already using container names (no change needed):
- ✅ **Prowlarr** → *arr apps (already configured with hostnames)
- ✅ **Overseerr** → Sonarr/Radarr (already configured with hostnames)
- ✅ **Bazarr** → Sonarr/Radarr (already configured with hostnames)

Only SABnzbd connections needed updating because they were originally configured via localhost when sharing the VPN network namespace.
