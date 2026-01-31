#!/bin/bash
# Immich Auto-Import Watcher
# Watches inbox folder and imports photos to Immich automatically

INBOX_FOLDER="${INBOX_FOLDER:-/inbox}"
IMMICH_URL="${IMMICH_INSTANCE_URL:-http://immich_server:2283}"
IMMICH_API_KEY="${IMMICH_API_KEY}"
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"  # 5 minutes default

echo "🚀 Immich Auto-Importer Started"
echo "📂 Watching: $INBOX_FOLDER"
echo "🔗 Immich URL: $IMMICH_URL"
echo "⏱️  Check interval: ${CHECK_INTERVAL}s"

# Install immich CLI
echo "📦 Installing Immich CLI..."
npm install -g @immich/cli

export IMMICH_INSTANCE_URL=$IMMICH_URL
export IMMICH_API_KEY=$IMMICH_API_KEY

echo "✅ Ready! Waiting for photos in inbox..."

while true; do
    # Check if inbox has any files
    if [ -n "$(find $INBOX_FOLDER -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.heif" -o -iname "*.raw" -o -iname "*.cr2" -o -iname "*.nef" -o -iname "*.dng" -o -iname "*.mp4" -o -iname "*.mov" \) 2>/dev/null | head -1)" ]; then
        echo "📸 Found photos in inbox! Starting import..."
        
        # Import photos
        immich upload $INBOX_FOLDER --recursive --delete
        
        if [ $? -eq 0 ]; then
            echo "✅ Import successful! Photos removed from inbox."
        else
            echo "❌ Import failed! Check logs. Photos NOT deleted."
        fi
    fi
    
    # Wait before checking again
    sleep $CHECK_INTERVAL
done
