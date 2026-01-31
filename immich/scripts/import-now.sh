#!/bin/bash
# Manual trigger for Immich auto-import
# Run this whenever you want to import immediately

echo "🔄 Triggering Immich import manually..."
docker exec immich_auto_import immich upload /inbox --recursive --delete

if [ $? -eq 0 ]; then
    echo "✅ Import completed!"
else
    echo "❌ Import failed - check logs with: docker logs immich_auto_import"
fi
