#!/bin/bash
# Integration script for adding Mailspring to Mission Control Dashboard
# This script updates the toolbox external_tools.json to include Mailspring

set -e

TOOLBOX_PATH="/Volumes/RAID5/Projects/_tools/toolbox"
EXTERNAL_TOOLS="${TOOLBOX_PATH}/external_tools.json"

echo "🚀 Mailspring Docker Integration Script"
echo "========================================"

# Check if toolbox path exists
if [ ! -d "$TOOLBOX_PATH" ]; then
    echo "❌ Toolbox directory not found: $TOOLBOX_PATH"
    echo "Please verify the path and try again."
    exit 1
fi

# Check if external_tools.json exists
if [ ! -f "$EXTERNAL_TOOLS" ]; then
    echo "⚠️  external_tools.json not found. Creating it..."
    echo "[]" > "$EXTERNAL_TOOLS"
fi

echo "📍 Toolbox location: $TOOLBOX_PATH"
echo "📋 External tools file: $EXTERNAL_TOOLS"
echo ""

echo "📧 Adding Mailspring to external tools..."

# Create temporary JSON with Mailspring entry
cat > /tmp/mailspring_entry.json << 'EOF'
{
  "name": "Mailspring",
  "description": "Beautiful, fast email client with local sync engine",
  "icon": "📧",
  "port": 6379,
  "url": "http://localhost:6379",
  "category": "Communication",
  "status": "running",
  "healthCheck": "http://localhost:6379/health",
  "features": [
    "Email Sync (IMAP/SMTP)",
    "Unified Inbox",
    "Local Encryption",
    "Plugin Architecture",
    "Link Tracking (Pro)"
  ],
  "networks": ["tools-network"]
}
EOF

# Use jq to add Mailspring to the array (if jq is available)
if command -v jq &> /dev/null; then
    echo "✓ Using jq to merge configurations..."
    
    # Check if Mailspring already exists
    if jq '.[] | select(.name == "Mailspring")' "$EXTERNAL_TOOLS" > /dev/null 2>&1; then
        echo "ℹ️  Mailspring already exists in external_tools.json. Updating..."
        jq '(.[] | select(.name == "Mailspring")) |= (. + input)' "$EXTERNAL_TOOLS" /tmp/mailspring_entry.json > /tmp/external_tools_new.json
    else
        echo "ℹ️  Adding new Mailspring entry..."
        jq '. += [input]' "$EXTERNAL_TOOLS" /tmp/mailspring_entry.json > /tmp/external_tools_new.json
    fi
    
    mv /tmp/external_tools_new.json "$EXTERNAL_TOOLS"
else
    echo "⚠️  jq not found. Please manually add this entry to $EXTERNAL_TOOLS:"
    echo ""
    cat /tmp/mailspring_entry.json
    echo ""
fi

echo "✅ Mailspring added to external tools!"
echo ""

# Restart toolbox if docker is available
if command -v docker &> /dev/null; then
    echo "🐳 Restarting toolbox container..."
    docker restart developer-toolbox 2>/dev/null || echo "⚠️  Could not restart toolbox (docker not running?)"
else
    echo "⚠️  Docker not found. Please restart toolbox manually:"
    echo "   docker restart developer-toolbox"
fi

echo ""
echo "✨ Integration complete!"
echo ""
echo "Next steps:"
echo "1. Build Mailspring: cd /Volumes/RAID5/Projects/_tools/mailspring && docker-compose build"
echo "2. Start service: docker-compose up -d"
echo "3. Access dashboard: http://localhost:2187"
echo "4. Open Mailspring: http://localhost:6379"
echo ""
echo "For detailed setup, see: DOCKER_SETUP.md or QUICKSTART.md"
