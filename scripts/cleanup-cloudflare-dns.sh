#!/bin/bash
# Script to delete Cloudflare DNS records for tunnel (to let Zero Trust manage them)

ZONE_ID="475d7017b03a27e393b0444367c98cc8"
API_TOKEN="ISK0NryCVEOIBhd6x0hdzT91Qq2zfVw8g_cgHL7a"

# DNS Record IDs to delete (tunnel-related CNAMEs)
declare -A records=(
  ["4a73818627f4edc1c36e2c857feccb22"]="bazarr.joeparachini.com"
  ["e9edcdd221c342fcb147beaa9fca7188"]="jellyfin.joeparachini.com"
  ["46917cd60bcc897935a2d6bd7d14fed0"]="lidarr.joeparachini.com"
  ["dd7cbc9c9539f56958fe67b4e5b59191"]="overseerr.joeparachini.com"
  ["790a977da135d3aaf7aeac0235177054"]="prowlarr.joeparachini.com"
  ["9994fc530fdb8ba07dfd71df146c4eda"]="radarr.joeparachini.com"
  ["3e8ab07657dad8a690833e5b095b3c38"]="sabnzbd.joeparachini.com"
  ["0407a5d36e61d92dc9435e382f54ec2a"]="sonarr.joeparachini.com"
)

echo "Deleting DNS records from main DNS section..."
echo "=============================================="

for record_id in "${!records[@]}"; do
  record_name="${records[$record_id]}"
  echo "Deleting: ${record_name}"
  
  response=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records/${record_id}" \
    -H "Authorization: Bearer ${API_TOKEN}" \
    -H "Content-Type: application/json")
  
  if echo "$response" | grep -q '"success":true'; then
    echo "✓ ${record_name} deleted"
  else
    echo "✗ Failed: ${record_name}"
    echo "  Response: $response"
  fi
  
  sleep 0.3
done

echo ""
echo "DNS cleanup complete!"
echo "=============================================="
echo "Note: Kept existing 'unifi.joeparachini.com' record"
echo ""
echo "Now you can add public hostnames in Zero Trust dashboard"
echo "and it will manage the DNS records automatically."
