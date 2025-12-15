# 🚀 Getting Started with Observability Swift Client

## 📥 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/artfularchivesstudio-spec/observability-swift-client.git
cd observability-swift-client
```

### 2. Set Up API Key Authentication

Run the automated setup script:

```bash
./scripts/setup-monitoring-api-key.sh
```

This will:
- Create `Secrets.xcconfig` with your API key
- Configure Xcode/XcodeGen to use the secrets
- Update `.gitignore` to protect your secrets

**Or manually create the config file:**

```bash
echo "MONITORING_API_KEY=your-api-key-here" > Observability/Observability/Secrets.xcconfig
```

### 3. Generate Xcode Project (if using XcodeGen)

```bash
xcodegen generate
```

### 4. Open in Xcode

```bash
open Observability.xcodeproj
```

### 5. Build and Run

- Select your target device (iOS Simulator or real device)
- Press `Cmd + R` to build and run
- The app will connect to the live monitoring server!

## 🔐 API Key Information

**Default API Key**: `observability-secret-key-2025`

**To change the API key:**
1. Update the key in the monitoring service: `/root/api-gateway/monitoring-service/.env`
2. Restart the monitoring service: `pm2 restart monitoring`
3. Run the setup script on your laptop with the new key

## 🌐 Connection Details

- **WebSocket URL**: `wss://api-router.cloud/monitoring/custom/`
- **HTTP URL**: `https://api-router.cloud/monitoring/custom/`
- **Authentication**: API key via query parameter or X-API-Key header

## 📱 What You'll See

When the app launches, you'll see:
1. 🔴 Connection status indicator
2. 📊 Real-time service health metrics
3. 📈 Live performance charts
4. 🚨 Active alerts and notifications
5. 🔄 Animated service status indicators

## 🎯 Next Steps

The app is now live-connected! Next features to implement:

### Phase 2.1: iOS Enhancement
- [ ] APNS Push Notifications for critical alerts
- [ ] Live Activities for real-time metrics
- [ ] Dynamic Island integration (iPhone 14 Pro+)
- [ ] iOS Widgets (Home Screen/Lock Screen)
- [ ] Siri Shortcuts
- [ ] Focus Mode support

### Phase 2.2: Apple Watch
- [ ] WatchOS companion app
- [ ] Custom complications
- [ ] Haptic alerts for critical issues

### Phase 2.3: macOS App
- [ ] Menu bar status indicator
- [ ] Floating monitor window

See `Roadmap.md` and `Observability/TODO.md` for complete details!

## 🔧 Troubleshooting

### "API Key not found in Info.plist"
Run the setup script: `./scripts/setup-monitoring-api-key.sh`

### Connection fails
- Verify API key matches server configuration
- Check that monitoring service is running: `pm2 list`
- Test WebSocket endpoint: `wscat -c wss://api-router.cloud/monitoring/custom/?api_key=your-key`

### Build errors
- Clean build folder: `Cmd + Shift + K`
- Reset package cache: `File > Packages > Reset Package Caches`

## 📚 Documentation

- `Roadmap.md` - Complete Apple ecosystem integration plan
- `Observability/TODO.md` - Immediate action items
- `scripts/SETUP.md` - Detailed setup guide
- `ObservabilityKit/README.md` - Swift Package documentation

## 🤝 Contributing

After making changes:
```bash
git add .
git commit -m "Your descriptive commit message"
git push
```

Remember: **NEVER commit Secrets.xcconfig** - it's already in .gitignore!

---

🎉 **You're all set!** The iOS app is now connected to live infrastructure monitoring. Enjoy real-time observability on your Apple devices!
