#!/bin/bash
# Script to configure Cloudflare DNS records for tunnel routing

ZONE_ID="475d7017b03a27e393b0444367c98cc8"
API_TOKEN="ISK0NryCVEOIBhd6x0hdzT91Qq2zfVw8g_cgHL7a"
TUNNEL_ID="adfc2864-430d-47dc-9ef7-843738042e43"

# Services to configure
declare -a services=(
  "jellyfin"
  "overseerr"
  "home"
  "sonarr"
  "radarr"
  "lidarr"
  "prowlarr"
  "sabnzbd"
  "bazarr"
)

echo "Creating DNS records for Cloudflare Tunnel..."
echo "=============================================="

for service in "${services[@]}"; do
  echo "Creating: ${service}.joeparachini.com"
  
  response=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json" \
    --data '{
      "type": "CNAME",
      "name": "'${service}'",
      "content": "'${TUNNEL_ID}'.cfargotunnel.com",
      "ttl": 1,
      "proxied": true,
      "comment": "Cloudflare Tunnel - Parachini HomeLab"
    }')
  
  # Check if successful
  if echo "$response" | grep -q '"success":true'; then
    echo "✓ ${service}.joeparachini.com created"
  elif echo "$response" | grep -q 'already exists'; then
    echo "○ ${service}.joeparachini.com already exists"
  else
    echo "✗ Failed: ${service}.joeparachini.com"
    echo "  Response: $response"
  fi
  
  sleep 0.5
done

echo ""
echo "DNS configuration complete!"
echo "=============================================="
echo ""
echo "Your services will be available at:"
for service in "${services[@]}"; do
  echo "  https://${service}.joeparachini.com"
done
echo ""
echo "Note: DNS propagation may take a few minutes."
