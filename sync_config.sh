#!/bin/bash

SOURCE_DIR="$HOME/Library/Application Support/Mailspring"
DEST_DIR="/Volumes/RAID5/Projects/_tools/mailspring/data/config"

echo "Syncing Mailspring config from native macOS to Docker volume..."

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR not found."
    exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

# Copy and strip passwords (which are encrypted with Mac Keychain and won't work in Linux)
jq 'del(."*".credentials) | del(."*".accounts[].settings.refresh_token) | del(."*".accounts[].settings.imap_password)' "$SOURCE_DIR/config.json" > "$DEST_DIR/config.json"

# Also copy to Mailspring-dev if the directory exists (or create it)
DEST_DEV_DIR="/Volumes/RAID5/Projects/_tools/mailspring/data/config-dev"
mkdir -p "$DEST_DEV_DIR"
cp "$DEST_DIR/config.json" "$DEST_DEV_DIR/config.json"

# Skip database files for now to avoid cross-platform SQLite issues
# if [ -f "$SOURCE_DIR/edgehill.db" ]; then
#     cp "$SOURCE_DIR/edgehill.db"* "$DEST_DIR/"
#     cp "$SOURCE_DIR/edgehill.db"* "$DEST_DEV_DIR/"
# fi

# Copy compile-cache and other potentially useful dirs if they aren't too big
# cp -R "$SOURCE_DIR/compile-cache" "$DEST_DIR/" 2>/dev/null

echo "Sync complete. Restarting Mailspring container..."
docker-compose restart mailspring
