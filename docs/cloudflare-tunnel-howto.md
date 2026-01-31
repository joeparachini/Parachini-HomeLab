# Cloudflare Tunnel - Adding New Services Guide

## 📌 Quick Reference

**Tunnel Details:**
- **Name:** parachini-homelab
- **Tunnel ID:** adfc2864-430d-47dc-9ef7-843738042e43
- **Domain:** joeparachini.com
- **Dashboard:** https://one.dash.cloudflare.com/

---

## 🚀 Adding a New Service to the Tunnel

### Step 1: Add Public Hostname Route

1. **Navigate to Cloudflare Zero Trust Dashboard:**
   - Go to: https://one.dash.cloudflare.com/

2. **Find Your Tunnel:**
   - Click: **Networks** → **Connectors**
   - Select: **parachini-homelab** tunnel
   - Click: **Edit**

3. **Add the Route:**
   - Go to: **Published application routes** tab
   - Click: **Add** button
   - Fill in the form:
     - **Public hostname:** `<subdomain>.joeparachini.com`
       - Example: `immich.joeparachini.com`
     - **Service type:** HTTP (or HTTPS if service has SSL)
     - **URL:** `<container_name>:<port>`
       - Example: `immich_server:2283`
       - Example: `jellyfin:8096`
   - Click: **Save**

4. **Verify Route:**
   - Wait 1-2 minutes for DNS propagation
   - Test: `curl -I https://<subdomain>.joeparachini.com`
   - Or visit in browser

### Step 2: Add Authentication (Optional)

**Note:** Only add authentication for admin/management services. Skip this for media services (Jellyfin, Plex, Immich) to keep mobile apps working.

1. **Navigate to Access Controls:**
   - Go to: **Access Controls** → **Applications**

2. **Select or Create Application:**
   - **Option A:** Add to existing application (if not at limit)
     - Select an existing application (e.g., "Homelab Services")
     - Click: **Edit**
   - **Option B:** Create new application (if limit reached)
     - Click: **Add an application**
     - Choose: **Self-hosted**
     - Name: `<Service Name>` (e.g., "Immich")

3. **Add the Hostname:**
   - Under "Application domain" or "Add hostnames"
   - Enter: `<subdomain>.joeparachini.com`
   - Example: `immich.joeparachini.com`

4. **Configure Policy:**
   - **Policy Name:** Allow Authorized Users
   - **Action:** Allow
   - **Rule type:** Include
   - **Selector:** Emails
   - **Value:** `joeparachini@gmail.com` (or other emails)
   
   For multiple users:
   - Add multiple email addresses separated by commas
   - Or use email domain matching: `*@yourdomain.com`

5. **Additional Settings:**
   - **Session Duration:** 24 hours (default, adjust as needed)
   - **Identity providers:** Google (should already be configured)

6. **Save Application**

---

## 📋 Common Service Examples

### Example 1: Media Service (No Auth - Mobile Friendly)

**Service:** Immich  
**Container:** immich_server  
**Port:** 2283

**Route Configuration:**
- Public hostname: `immich.joeparachini.com`
- Service type: HTTP
- URL: `immich_server:2283`
- **Authentication:** None (skip Step 2)

**Why no auth?** Mobile apps need direct API access without OAuth redirects.

---

### Example 2: Admin Service (With Auth)

**Service:** Sonarr  
**Container:** sonarr  
**Port:** 8989

**Route Configuration:**
- Public hostname: `sonarr.joeparachini.com`
- Service type: HTTP
- URL: `sonarr:8989`
- **Authentication:** Yes (complete Step 2)

**Why auth?** Admin tools should be protected behind Google OAuth.

---

### Example 3: External Service (Outside Docker)

**Service:** Plex (on Windows machine)  
**IP:** 192.168.1.136  
**Port:** 32400

**Route Configuration:**
- Public hostname: `plex.joeparachini.com`
- Service type: HTTP
- URL: `192.168.1.136:32400`
- **Authentication:** None (Plex has native auth)

**Note:** Use IP address for services outside the Docker network.

---

## 🔧 Updating Homepage Dashboard

After adding a service to Cloudflare tunnel, update your homepage:

**File:** `/home/joe/Parachini-HomeLab/config/homepage/services.yaml`

```yaml
- Category Name:
    - Service Name:
        icon: service-icon.png
        href: https://<subdomain>.joeparachini.com
        description: Service Description
        widget:
          type: service-type
          url: http://<container_name>:<port>
          key: {{HOMEPAGE_VAR_API_KEY}}  # if needed
```

**Example:**
```yaml
- Photos:
    - Immich:
        icon: immich.png
        href: https://immich.joeparachini.com
        description: Photo Management & Sharing
        widget:
          type: immich
          url: http://immich_server:2283
          key: {{HOMEPAGE_VAR_IMMICH_API_KEY}}
```

**Important:**
- `href`: Use the **public** HTTPS domain
- `url` (widget): Use the **internal** Docker service name

---

## 🐳 Docker Network Requirements

For a service to be accessible via Cloudflare tunnel:

1. **Service must be on the `proxy` network:**

```yaml
# In docker-compose.yml
services:
  your-service:
    container_name: your_service
    networks:
      - proxy

networks:
  proxy:
    external: true
```

2. **Verify network connection:**
```bash
docker network inspect proxy | grep -A 5 "your_service"
```

3. **Connect existing container to proxy network:**
```bash
docker network connect proxy <container_name>
```

---

## 🔍 Troubleshooting

### Service Returns 502/503 Error

**Check container status:**
```bash
docker ps | grep <service_name>
```

**Check if container is on proxy network:**
```bash
docker inspect <container_name> | grep -A 10 Networks
```

**Check cloudflared logs:**
```bash
docker logs cloudflared --tail 50
```

**Restart cloudflared:**
```bash
docker restart cloudflared
```

### DNS Not Resolving

- Wait 1-2 minutes for DNS propagation
- Check DNS: `nslookup <subdomain>.joeparachini.com`
- Verify route is saved in Cloudflare dashboard
- Clear browser DNS cache: `chrome://net-internals/#dns`

### Authentication Loop / Not Working

**Check Access policy:**
1. Go to: Access Controls → Applications
2. Verify hostname is listed
3. Check policy includes your email
4. Verify Google OAuth is configured

**Check session:**
- Clear cookies for `*.cloudflareaccess.com`
- Try incognito mode
- Check if email matches exactly

**Common fix:**
```bash
# Restart cloudflared
docker restart cloudflared

# Check tunnel status
docker logs cloudflared
```

### Mobile App Can't Connect (Media Services)

**Issue:** Service has Cloudflare Access enabled

**Solution:** Remove authentication for that service:
1. Go to: Access Controls → Applications
2. Remove the hostname from protected applications
3. Mobile apps need direct API access without OAuth

---

## 📊 Current Services

| Service | URL | Container:Port | Auth |
|---------|-----|----------------|------|
| Dashboard | https://dashboard.joeparachini.com | homepage:3000 | 🔒 Yes |
| Jellyfin | https://jellyfin.joeparachini.com | jellyfin:8096 | ❌ No |
| Plex | https://plex.joeparachini.com | 192.168.1.136:32400 | ❌ No |
| Overseerr | https://overseerr.joeparachini.com | overseerr:5055 | 🔒 Yes |
| Sonarr | https://sonarr.joeparachini.com | sonarr:8989 | 🔒 Yes |
| Radarr | https://radarr.joeparachini.com | radarr:7878 | 🔒 Yes |
| Lidarr | https://lidarr.joeparachini.com | lidarr:8686 | 🔒 Yes |
| Prowlarr | https://prowlarr.joeparachini.com | prowlarr:9696 | 🔒 Yes |
| SABnzbd | https://sabnzbd.joeparachini.com | sabnzbd:8080 | 🔒 Yes |
| Bazarr | https://bazarr.joeparachini.com | bazarr:6767 | 🔒 Yes |
| **Immich** | **https://immich.joeparachini.com** | **immich_server:2283** | **❌ No** |

---

## 🔐 Authentication Strategy

### Services WITHOUT Authentication (Public Access)
- **Media Services:** Jellyfin, Plex, Immich
- **Reason:** Mobile apps, TV apps, casting requires direct API access
- **Security:** These services have their own built-in authentication

### Services WITH Authentication (Google OAuth)
- **Admin Tools:** Sonarr, Radarr, Lidarr, Prowlarr, SABnzbd, Bazarr
- **Dashboards:** Homepage
- **Reason:** Sensitive management interfaces should be protected
- **Who can access:** Only emails listed in Access policy

---

## 📝 Quick Checklist for Adding a Service

- [ ] Service is running (`docker ps`)
- [ ] Service is on `proxy` network (`docker network inspect proxy`)
- [ ] Add route in Cloudflare: Networks → Connectors → parachini-homelab → Edit → Published application routes → Add
- [ ] (Optional) Add auth in Cloudflare: Access Controls → Applications → Add hostname
- [ ] Update homepage config: `config/homepage/services.yaml`
- [ ] Test URL: `https://<subdomain>.joeparachini.com`
- [ ] Update this documentation with new service

---

## 🛠️ Useful Commands

```bash
# Check tunnel status
docker ps -f name=cloudflared

# View tunnel logs
docker logs cloudflared --tail 50

# Follow tunnel logs in real-time
docker logs -f cloudflared

# Restart tunnel
docker restart cloudflared

# Check which containers are on proxy network
docker network inspect proxy -f '{{range .Containers}}{{.Name}} {{end}}'

# Connect a container to proxy network
docker network connect proxy <container_name>

# Test a service URL
curl -I https://<subdomain>.joeparachini.com

# Check DNS resolution
nslookup <subdomain>.joeparachini.com

# View all running services
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 📚 Additional Resources

- **Cloudflare Zero Trust Docs:** https://developers.cloudflare.com/cloudflare-one/
- **Tunnel Documentation:** https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- **Access Documentation:** https://developers.cloudflare.com/cloudflare-one/policies/access/

---

**Last Updated:** 2026-01-31  
**Maintained By:** Joe Parachini  
**Questions?** Check Cloudflare dashboard or homelab documentation
