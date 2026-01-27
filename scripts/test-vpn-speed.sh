#!/bin/bash
# Test different VPN servers to find fastest one

set -e

HOMELAB_DIR="/home/joe/Parachini-HomeLab"
cd "$HOMELAB_DIR"

# Servers to test (closest/fastest locations typically)
SERVERS=(
    "United States"
    "Atlanta"
    "Chicago"
    "Dallas"
    "New York"
    "Los Angeles"
    "Miami"
    "Phoenix"
    "Seattle"
    "Canada"
)

echo "==================================================================="
echo "           VPN Speed Test - Finding Fastest Server"
echo "==================================================================="
echo ""
echo "Testing ${#SERVERS[@]} server locations..."
echo "Each test downloads 100MB file to measure speed"
echo ""

RESULTS_FILE="/tmp/vpn-speed-results.txt"
> "$RESULTS_FILE"  # Clear file

for server in "${SERVERS[@]}"; do
    echo "-------------------------------------------------------------------"
    echo "Testing: $server"
    echo "-------------------------------------------------------------------"
    
    # Update .env with new server
    sed -i "s/^SERVER_COUNTRIES=.*/SERVER_COUNTRIES=$server/" .env
    
    # Restart Gluetun
    echo "Restarting Gluetun with $server server..."
    docker-compose restart gluetun > /dev/null 2>&1
    
    # Wait for VPN to connect
    echo -n "Waiting for connection"
    for i in {1..30}; do
        if docker exec gluetun sh -c 'cat /tmp/gluetun/ip' > /dev/null 2>&1; then
            echo " ✓"
            break
        fi
        echo -n "."
        sleep 2
    done
    
    # Get connected IP
    VPN_IP=$(docker exec gluetun cat /tmp/gluetun/ip 2>/dev/null || echo "Unknown")
    echo "Connected - IP: $VPN_IP"
    
    # Run speed test
    echo -n "Testing speed... "
    SPEED=$(docker exec gluetun sh -c 'wget -O /dev/null http://ipv4.download.thinkbroadband.com/100MB.zip 2>&1' | \
            grep -oP '\(\K[0-9.]+ [MK]B/s' | head -1 || echo "FAILED")
    
    if [ "$SPEED" != "FAILED" ]; then
        echo "✓ $SPEED"
        echo "$server|$SPEED|$VPN_IP" >> "$RESULTS_FILE"
    else
        echo "✗ Failed"
        echo "$server|FAILED|$VPN_IP" >> "$RESULTS_FILE"
    fi
    
    sleep 2
done

echo ""
echo "==================================================================="
echo "                         RESULTS"
echo "==================================================================="
echo ""
printf "%-20s | %-15s | %-20s\n" "Server" "Speed" "IP Address"
echo "-------------------------------------------------------------------"

# Sort by speed (convert to MB/s for sorting)
while IFS='|' read -r server speed ip; do
    printf "%-20s | %-15s | %-20s\n" "$server" "$speed" "$ip"
done < <(sort -t'|' -k2 -rh "$RESULTS_FILE")

echo ""
echo "==================================================================="

# Find fastest
FASTEST=$(sort -t'|' -k2 -rh "$RESULTS_FILE" | head -1 | cut -d'|' -f1)
FASTEST_SPEED=$(sort -t'|' -k2 -rh "$RESULTS_FILE" | head -1 | cut -d'|' -f2)

echo ""
echo "🏆 FASTEST SERVER: $FASTEST ($FASTEST_SPEED)"
echo ""
read -p "Switch to $FASTEST permanently? (y/n): " choice

if [ "$choice" = "y" ]; then
    sed -i "s/^SERVER_COUNTRIES=.*/SERVER_COUNTRIES=$FASTEST/" .env
    docker-compose restart gluetun
    echo "✓ Switched to $FASTEST"
    echo "✓ Gluetun restarted"
else
    echo "Keeping current server"
fi

echo ""
echo "Results saved to: $RESULTS_FILE"
