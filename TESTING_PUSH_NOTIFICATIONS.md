# 🔔 Testing Push Notifications Guide

## Current Implementation Status

### ✅ What's Implemented: **Local Notifications**
The app currently uses **local notifications** (sent from within the app), not remote push notifications (APNS).

**Local notifications work when:**
- App is running (foreground or background)
- App has notification permissions
- Service status changes trigger alerts

### ❌ What's Missing: **Remote Push Notifications (APNS)**
True push notifications from a server require:
- APNS certificate/key setup
- Device token registration
- Backend endpoint to send push notifications
- APNS server integration

## How to Test Local Notifications

### 1. **Check Notification Permissions**

Run the app and check if permissions are granted:

```swift
// In DashboardView, there's a button to request permissions
// Or check in Settings > Notifications > Observability
```

### 2. **Trigger a Service Status Change**

The easiest way to test is to simulate a service going down:

**Option A: Simulate in Code**
Add this temporary test function to `DashboardViewModel.swift`:

```swift
// Add to DashboardViewModel for testing
func testSendNotification() async {
    let testAlert = ObservabilityCore.Alert(
        id: UUID(),
        serviceId: services.first?.id ?? UUID(),
        serviceName: "Test Service",
        title: "Test Critical Alert",
        message: "This is a test notification to verify push notifications work",
        severity: .critical,
        timestamp: Date(),
        resolved: false,
        metadata: [:]
    )
    
    await pushNotificationsManager.sendCriticalAlert(testAlert)
}
```

Then call it from `DashboardView`:

```swift
Button("Test Notification") {
    Task {
        await viewModel.testSendNotification()
    }
}
```

**Option B: Actually Break a Service**
- Stop a service on the server (e.g., `pm2 stop strapi`)
- Wait for health check to detect it's down
- Notification should trigger automatically

### 3. **Test Different Notification Types**

The app sends different notifications for different scenarios:

- **Critical Alerts**: When service goes down
- **Error Alerts**: When errors occur
- **Warning Alerts**: When warnings are detected
- **Status Changes**: When service status changes (down → operational, etc.)

### 4. **Verify Notification Appears**

**When App is in Foreground:**
- Notification should appear as a banner at the top
- Sound should play
- Badge should update

**When App is in Background:**
- Notification should appear in Notification Center
- Lock screen should show notification
- Sound should play

**When App is Closed:**
- Notification should appear in Notification Center
- Lock screen should show notification
- Sound should play

## Testing Checklist

- [ ] App requests notification permissions on launch
- [ ] User grants notification permissions
- [ ] Critical alert triggers notification
- [ ] Error alert triggers notification
- [ ] Warning alert triggers notification
- [ ] Service status change triggers notification
- [ ] Notification appears when app is in foreground
- [ ] Notification appears when app is in background
- [ ] Notification appears when app is closed
- [ ] Notification sound plays
- [ ] Notification badge updates
- [ ] Tapping notification opens app (if implemented)

## Debugging Notification Issues

### Check Authorization Status

Add this to `DashboardView` to see current status:

```swift
Text("Notification Status: \(viewModel.pushNotificationsManager.authorizationStatus.rawValue)")
```

### Check Console Logs

Look for these messages:
- `"Failed to send critical alert: ..."` - indicates notification failed
- No errors = notification was scheduled successfully

### Verify Permissions

1. Go to Settings > Notifications > Observability
2. Ensure "Allow Notifications" is ON
3. Check that "Sounds" and "Badges" are enabled

## What About Remote Push Notifications (APNS)?

To implement **true remote push notifications**, you need:

### 1. **APNS Setup**
- Create APNS certificate/key in Apple Developer Portal
- Configure app with APNS capability
- Set up APNS environment (development/production)

### 2. **Device Token Registration**
Add to `AppDelegate.swift`:

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(token)")
    // Send token to your backend
}

func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
) {
    print("Failed to register for remote notifications: \(error)")
}
```

### 3. **Backend Integration**
- Create endpoint to receive device tokens
- Store device tokens in database
- Send push notifications via APNS when alerts occur
- Use APNS HTTP/2 API or APNs Provider API

### 4. **Testing Remote Push**
- Use APNS sandbox for development
- Use real device (simulator doesn't support remote push)
- Test with production APNS for production builds

## Current Limitations

1. **Local notifications only** - Work when app is running or recently closed
2. **No remote push** - Can't send notifications when app hasn't been opened in a while
3. **No device token** - Can't receive notifications from server
4. **No backend integration** - Server can't push notifications to devices

## Next Steps

To implement full APNS push notifications:

1. ✅ Local notifications (DONE)
2. ⏳ APNS certificate setup
3. ⏳ Device token registration
4. ⏳ Backend push endpoint
5. ⏳ APNS server integration
6. ⏳ Testing on real device

See `TODO.md` for full APNS implementation checklist.

