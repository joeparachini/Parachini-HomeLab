#!/bin/bash
# Script to manually trigger Plex library scans from Linux host
# Usage: ./scan-plex.sh

# Your Plex server details
PLEX_URL="http://YOUR_WINDOWS_PC_IP:32400"  # Change to your Windows PC IP
PLEX_TOKEN="YOUR_PLEX_TOKEN"  # Get from: https://support.plex.tv/articles/204059436-finding-an-authentication-token-x-plex-token/

# Scan all libraries
echo "Triggering Plex library scans..."
curl -X GET "${PLEX_URL}/library/sections/all/refresh?X-Plex-Token=${PLEX_TOKEN}"

echo "Scan triggered!"
