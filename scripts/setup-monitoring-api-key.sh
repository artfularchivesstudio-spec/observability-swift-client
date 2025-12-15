#!/bin/bash
#
# 🔐 Setup Monitoring API Key for iOS Observability App
#
# This script creates the necessary environment file with the API key
# for connecting to the live monitoring server.
#
# Usage: ./scripts/setup-monitoring-api-key.sh
#
# 📜 The Cosmic Setup Ritual - Where Secrets Are Safely Stored ✨

set -e

# 🎭 Colors for theatrical output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🎭 THE COSMIC API KEY SETUP RITUAL - ACT I 🎭           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# 📁 Project root detection
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🔍 Detecting project structure...${NC}"
echo "📂 Project root: $PROJECT_ROOT"
echo ""

# 🔐 Default API key (consider changing in production)
DEFAULT_API_KEY="observability-secret-key-2025"

# Ask for custom API key if desired
echo -e "${YELLOW}🤔 Would you like to use the default API key or enter a custom one?${NC}"
echo -e "${BLUE}   Press Enter for default: $DEFAULT_API_KEY${NC}"
read -p "   Custom API key (or press Enter): " CUSTOM_API_KEY

FINAL_API_KEY="${CUSTOM_API_KEY:-$DEFAULT_API_KEY}"

echo ""
echo -e "${GREEN}✨ Using API key: ${FINAL_API_KEY:0:10}...${NC}"
echo ""

# 📄 Environment file creation
echo -e "${BLUE}📝 Creating environment file...${NC}"

# For iOS App (Xcode)
IOS_ENV_FILE="$PROJECT_ROOT/Observability/Observability/Secrets.xcconfig"

cat > "$IOS_ENV_FILE" << EOF
// 🎭 The Cosmic Configuration - Auto-generated, do not commit!
//
// This file contains sensitive configuration for the Observability app.
// It is intentionally excluded from git to protect secrets.
//
// Generated on: $(date)

// 🔐 Monitoring API Key - The Key to the Cosmic Gates
MONITORING_API_KEY = $FINAL_API_KEY

// 🌐 WebSocket Endpoint
MONITORING_WEBSOCKET_URL = wss://api-router.cloud/monitoring/custom/
MONITORING_HTTP_URL = https://api-router.cloud/monitoring/custom/
EOF

echo "   ✓ Created iOS config: $IOS_ENV_FILE"
echo ""

# 🔧 Update .gitignore if needed
GITIGNORE="$PROJECT_ROOT/.gitignore"

if [ -f "$GITIGNORE" ]; then
    if ! grep -q "Secrets.xcconfig" "$GITIGNORE"; then
        echo -e "${BLUE}🛡️  Updating .gitignore to protect secrets...${NC}"
        echo "" >> "$GITIGNORE"
        echo "# 🔐 Observatory Secrets - Do not commit!" >> "$GITIGNORE"
        echo "Observability/Observability/Secrets.xcconfig" >> "$GITIGNORE"
        echo "*.xcconfig" >> "$GITIGNORE"
        echo ".env*" >> "$GITIGNORE"
        echo "   ✓ Updated .gitignore"
    fi
else
    echo -e "${YELLOW}⚠️  .gitignore not found, creating one...${NC}"
    cat > "$GITIGNORE" << EOF
# 🔐 Observatory Secrets - Do not commit!
Observability/Observability/Secrets.xcconfig
*.xcconfig
.env*
EOF
    echo "   ✓ Created .gitignore"
fi

echo ""

# 🎨 Create XcodeGen config if it exists
XCODEGEN_YML="$PROJECT_ROOT/project.yml"
if [ -f "$XCODEGEN_YML" ]; then
    echo -e "${BLUE}🔧 Updating XcodeGen configuration...${NC}"

    # Check if Secrets.xcconfig is already referenced
    if ! grep -q "Secrets.xcconfig" "$XCODEGEN_YML"; then
        cat >> "$XCODEGEN_YML" << EOF

# 🔐 Observatory Secrets
# Include this in your target's settings:
# settings:
#   base:
#     INFOPLIST_FILE: Observability/Info.plist
#     SWIFT_VERSION: "5.9"
#   configs:
#     Debug:
#       xcconfig: Observability/Observability/Secrets.xcconfig
#     Release:
#       xcconfig: Observability/Observability/Secrets.xcconfig
EOF
        echo "   ✓ Updated project.yml with secrets reference"
    fi
    echo ""
fi

# 📱 Create Info.plist references if needed
INFO_PLIST="$PROJECT_ROOT/Observability/Observability/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo -e "${BLUE}📋 Checking Info.plist for API key references...${NC}"

    # Note: In production, consider using Keychain instead of Info.plist
    echo "   ℹ️  For production apps, use Keychain to store API keys securely"
    echo ""
fi

# 🎭 Final ceremony
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║        🔐 SETUP COMPLETE - THE GATES ARE OPEN! 🔐         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

echo -e "${BLUE}🎯 Next Steps:${NC}"
echo ""
echo "1. 🔐 Review the created file (optional):"
echo "   cat $IOS_ENV_FILE"
echo ""
echo "2. 📦 If using XcodeGen, regenerate your project:"
echo -e "   ${YELLOW}xcodegen generate${NC}"
echo ""
echo "3. 🚀 Open in Xcode and build:"
echo -e "   ${YELLOW}open Observability.xcodeproj${NC}"
echo ""
echo "4. ▶️  Run the app - it will connect to the live monitoring server!"
echo ""

echo -e "${BLUE}🎭 Theatrical Note:${NC}"
echo "   The cosmic secrets are now safely stored in your local realm."
echo "   Remember: Never commit Secrets.xcconfig to version control!"
echo ""

echo -e "${GREEN}✨ Live long and monitor! 🖖${NC}"
echo ""
