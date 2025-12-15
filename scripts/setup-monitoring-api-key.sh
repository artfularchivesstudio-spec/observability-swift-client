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

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 🎭 Theatrical banner
echo ""
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║           🔐 THE COSMIC API KEY RITUAL 🔐                 ║${NC}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Find project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Default API key (this is the key configured on the server)
DEFAULT_API_KEY="observability-secret-key-2025"

# Check if Secrets.xcconfig already exists
IOS_ENV_FILE="$PROJECT_ROOT/Observability/Observability/Secrets.xcconfig"

if [ -f "$IOS_ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  Secrets file already exists!${NC}"
    read -p "Do you want to overwrite it? (y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}✓ Keeping existing secrets file.${NC}"
        echo ""
        exit 0
    fi
fi

# Prompt for custom API key
echo -e "${BLUE}🗝️  Enter your API key (or press Enter to use default):${NC}"
read -p "API Key: " CUSTOM_API_KEY

# Use custom key or default
FINAL_API_KEY="${CUSTOM_API_KEY:-$DEFAULT_API_KEY}"

# Create the secrets file
echo -e "${CYAN}🔧 Creating Secrets.xcconfig...${NC}"

cat > "$IOS_ENV_FILE" << EOF
// 🔐 The Cosmic Configuration - Auto-generated, do not commit!
// This file contains sensitive configuration for the Observability app.
// It is intentionally excluded from git to protect secrets.

// 🌐 Generated on: $(date)

// 🔐 Monitoring API Key - The Key to the Cosmic Gates
MONITORING_API_KEY = $FINAL_API_KEY

// 🌐 WebSocket Endpoint - Where the Magic Happens ✨
MONITORING_WEBSOCKET_URL = wss://api-router.cloud/monitoring/custom/

// 📡 HTTP Endpoint - For RESTful Communications
MONITORING_HTTP_URL = https://api-router.cloud/monitoring/custom/
EOF

# Verify file was created
if [ -f "$IOS_ENV_FILE" ]; then
    echo -e "${GREEN}✓ Secrets.xcconfig created successfully!${NC}"
else
    echo -e "${RED}✗ Failed to create Secrets.xcconfig${NC}"
    exit 1
fi

# Update .gitignore to protect secrets
echo -e "${CYAN}🛡️  Updating .gitignore...${NC}"

GITIGNORE="$PROJECT_ROOT/.gitignore"

# Add multiple patterns to ensure secrets are protected
SECRETS_PATTERNS=(
    "Observability/Observability/Secrets.xcconfig"
    "*/Secrets.xcconfig"
    "*.xcconfig"
    ".env*"
    "*.env"
    "*.key"
    "*.pem"
    "*.p12"
    "*.mobileprovision"
)

for pattern in "${SECRETS_PATTERNS[@]}"; do
    if ! grep -q "$pattern" "$GITIGNORE" 2>/dev/null; then
        echo "$pattern" >> "$GITIGNORE"
    fi
done

echo -e "${GREEN}✓ .gitignore updated with secret protections${NC}"

# Display success message
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        🔐 SETUP COMPLETE - THE GATES ARE OPEN! 🔐         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo ""
echo -e "   1. 🔐 Review the created file (optional):${NC}"
echo -e "      ${CYAN}cat $IOS_ENV_FILE${NC}"
echo ""
echo -e "   2. 📦 If using XcodeGen, regenerate your project:${NC}"
echo -e "      ${CYAN}xcodegen generate${NC}"
echo ""
echo -e "   3. 🚀 Open in Xcode and build:${NC}"
echo -e "      ${CYAN}open Observability.xcodeproj${NC}"
echo ""
echo -e "   4. ▶️  Run the app - it will connect to the live monitoring server!${NC}"
echo ""
echo -e "${YELLOW}⚠️  Note: XcodeGen is not installed on this server.${NC}"
echo -e "${YELLOW}         Install it on your Mac with: brew install xcodegen${NC}"
echo ""
echo -e "${MAGENTA}🎭 Theatrical Note:${NC}"
echo -e "   The cosmic secrets are now safely stored in your local realm."
echo -e "   ${RED}Remember: Never commit Secrets.xcconfig to version control!${NC}"
echo ""
echo -e "${GREEN}✨ Live long and monitor! 🖖${NC}"
echo ""
