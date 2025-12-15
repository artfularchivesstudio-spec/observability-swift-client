# 🔐 Observatory API Key Setup

This setup script creates the necessary configuration for connecting the iOS Observability app to the live monitoring server.

## 📦 What It Does

1. **Creates `Secrets.xcconfig`** with API key and endpoints
2. **Updates `.gitignore`** to prevent committing secrets
3. **Configures Xcode/XcodeGen** to use the secrets file
4. **Provides setup instructions**

## 🚀 Quick Start

```bash
# From the repository root
cd observability-swift-client

# Run the setup script
./scripts/setup-monitoring-api-key.sh

# When prompted, press Enter for default API key
# Or enter a custom one if you've changed it on the server

# If using XcodeGen
xcodegen generate

# Open in Xcode
open Observability.xcodeproj

# Build and run! 🎉
```

## 🔒 Security

- **Never** commit `Secrets.xcconfig` to git
- **Never** share your API key publicly
- **Always** use `.gitignore` to protect secrets
- **Consider** using Keychain for production apps

## ⚙️ Configuration

The script creates `Observability/Observability/Secrets.xcconfig`:

```xcconfig
// 🔐 API Key
MONITORING_API_KEY = your-api-key-here

// 🌐 Endpoints
MONITORING_WEBSOCKET_URL = wss://api-router.cloud/monitoring/custom/
MONITORING_HTTP_URL = https://api-router.cloud/monitoring/custom/
```

## 🎭 Troubleshooting

**Problem**: App shows "API Key not found in Info.plist"

**Solution**: Run the setup script:
```bash
./scripts/setup-monitoring-api-key.sh
```

**Problem**: Connection fails with 401 Unauthorized

**Solution**:
1. Check the API key in your `.env` file
2. Run: `pm2 restart monitoring --update-env`
3. Re-run the setup script with the correct key

**Problem**: Can't connect to monitoring server

**Solution**:
1. Verify server is running: `pm2 list`
2. Check nginx config: `/root/api-gateway/nginx.conf`
3. Check server logs: `pm2 logs monitoring`

## 📱 For Production

For production apps, consider:

1. **Keychain Services** instead of Info.plist
2. **Certificate pinning** for extra security
3. **Environment-specific keys** (dev/staging/prod)
4. **Key rotation** policies

## 🤖 Automation

Add to your deployment:

```bash
# In your deploy script
./scripts/setup-monitoring-api-key.sh <<EOF
$MONITORING_API_KEY
EOF
```

## 🎪 Support

Need help? Check:
- Main README: `/README.md`
- Server setup: `/OBSERVABILITY.md`
- PM2 docs: [PM2 Documentation](https://pm2.keymetrics.io/)

Live long and monitor! 🖖✨
