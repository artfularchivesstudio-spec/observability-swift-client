# ⚡ Quick Reference Guide

## 🚀 Common Tasks

### Running the App
```bash
# Generate project
xcodegen generate

# Open in Xcode
open Observability.xcodeproj

# Build
xcodebuild build -scheme Observability

# Run tests
xcodebuild test -scheme Observability
```

### Testing
```bash
# All tests
make test

# Unit tests only
xcodebuild test -only-testing:ObservabilityTests

# UI tests only
xcodebuild test -only-testing:ObservabilityUITests
```

### Configuration
```bash
# Set up API key
./scripts/setup-monitoring-api-key.sh

# Check XcodeGen version
make check-xcodegen
```

## 📱 iOS Features Quick Reference

### Haptics
```swift
HapticsManager.shared.playCriticalAlert()
HapticsManager.shared.playServiceDown()
HapticsManager.shared.playSelection()
```

### Push Notifications
```swift
// Request permissions
await PushNotificationsManager.shared.requestAuthorization()

// Send notification
await PushNotificationsManager.shared.sendCriticalAlert(alert)
```

### Live Activities
```swift
// Start activity
await LiveActivitiesManager.shared.startServiceMonitoringActivity(
    service: service,
    health: health
)

// Update activity
await LiveActivitiesManager.shared.updateServiceMonitoringActivity(
    serviceName: service.name,
    health: health
)
```

### Dynamic Island
```swift
// Start Dynamic Island for critical service
await DynamicIslandManager.shared.startCriticalServiceMonitoring(
    service: service,
    health: health
)
```

## 🔧 Troubleshooting

### Build Issues
```bash
# Clean and regenerate
make clean && make generate-force

# Reset package cache
# Xcode > File > Packages > Reset Package Caches
```

### Test Issues
```bash
# Clean test data
xcodebuild clean test -scheme Observability

# Run with verbose output
xcodebuild test -scheme Observability -verbose
```

### Connection Issues
- Check API key in `Secrets.xcconfig`
- Verify monitoring service is running: `pm2 list`
- Test endpoint: `curl https://api-router.cloud/monitoring/custom/api/logs/stream?api_key=your-key`

## 📚 Documentation Links

- [Full Documentation](DOCUMENTATION.md)
- [API Reference](API_DOCUMENTATION.md)
- [User Guide](USER_GUIDE.md)
- [Testing Guide](TESTING_GUIDE.md)

## 🎯 Key Files

- `DashboardView.swift` - Main dashboard UI
- `DashboardViewModel.swift` - Dashboard logic
- `ErrorDetailView.swift` - Alert detail view
- `ServiceDetailView.swift` - Service detail view
- `HapticsManager.swift` - Haptic feedback
- `PushNotificationsManager.swift` - Push notifications
- `LiveActivitiesManager.swift` - Live Activities

---

*Quick reference for daily development* ⚡

