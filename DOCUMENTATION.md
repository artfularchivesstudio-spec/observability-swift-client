# 📚 Observability Swift Client - Comprehensive Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Reference](#api-reference)
4. [Testing Guide](#testing-guide)
5. [iOS Features](#ios-features)
6. [Deployment](#deployment)
7. [Troubleshooting](#troubleshooting)

## Overview

The Observability Swift Client is a comprehensive, cross-platform observability solution for Apple platforms that provides real-time monitoring, metrics collection, and distributed tracing capabilities.

### Key Features

- **Real-Time Monitoring**: Live health checks and status updates via WebSocket/SSE
- **Multi-Platform Support**: iOS, iPadOS, macOS, watchOS, tvOS
- **Push Notifications**: Critical alert notifications with haptic feedback
- **Live Activities**: Real-time metrics in Dynamic Island and Lock Screen
- **Comprehensive Testing**: Unit tests, integration tests, and visual snapshot tests
- **Beautiful UI**: SwiftUI components with smooth animations

## Architecture

### Module Structure

```
ObservabilityKit/
├── ObservabilityCore/      # Core models and protocols
├── ObservabilityNetworking/ # HTTP and WebSocket clients
├── ObservabilityUI/         # SwiftUI components
└── ObservabilityCommon/     # Shared utilities
```

### Key Components

#### DashboardViewModel
The main view model that orchestrates monitoring, health checks, and alert management.

**Responsibilities:**
- Service health monitoring
- Log streaming and parsing
- Alert generation and management
- Metrics collection
- Integration with push notifications and Live Activities

**Key Methods:**
- `startMonitoring()` - Begin monitoring all services
- `stopMonitoring()` - Stop all monitoring tasks
- `checkServiceHealth(_:)` - Check individual service health

#### HapticsManager
Manages haptic feedback for user interactions and alerts.

**Usage:**
```swift
HapticsManager.shared.playCriticalAlert()
HapticsManager.shared.playServiceDown()
```

#### PushNotificationsManager
Handles push notification authorization and delivery.

**Usage:**
```swift
await PushNotificationsManager.shared.requestAuthorization()
await PushNotificationsManager.shared.sendCriticalAlert(alert)
```

#### LiveActivitiesManager
Manages Live Activities for real-time service monitoring.

**Usage:**
```swift
await LiveActivitiesManager.shared.startServiceMonitoringActivity(
    service: service,
    health: health
)
```

## API Reference

### Models

#### ServiceInfo
Represents a monitored service.

```swift
public struct ServiceInfo: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var type: ServiceType
    public var port: Int?
    public var baseURL: URL?
    public var category: ServiceCategory
    public var description: String?
    public var icon: String?
    public var tags: Set<String>
}
```

#### Alert
Represents an alert or notification.

```swift
public struct Alert: Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let message: String
    public let severity: AlertSeverity
    public let source: AlertSource
    public let timestamp: Date
    public let acknowledged: Bool
    public let resolved: Bool
    public let tags: Set<String>
    public var metadata: [String: String]
}
```

#### HealthCheckResult
Contains the result of a health check.

```swift
public struct HealthCheckResult: Codable {
    public let serviceId: UUID
    public let timestamp: Date
    public let status: ServiceStatus
    public let responseTime: TimeInterval
    public let metrics: [String: MetricValue]
    public let checks: [String: CheckResult]
}
```

### Protocols

#### AlertManaging
Protocol for alert management operations.

```swift
public protocol AlertManaging {
    func createAlert(_ alert: Alert) async throws
    func acknowledgeAlert(_ alertId: UUID) async throws
    func resolveAlert(_ alertId: UUID) async throws
    func getActiveAlerts() async throws -> [Alert]
}
```

## Testing Guide

### Unit Tests

Unit tests are located in `ObservabilityTests/` and cover:

- **DashboardViewModelTests**: View model logic and state management
- **AlertModelTests**: Alert model validation and calculations
- **ServiceStatusTests**: Service status enum behavior
- **HTTPClientTests**: Network client functionality

**Running Tests:**
```bash
# Run all tests
xcodebuild test -scheme Observability -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Run specific test suite
xcodebuild test -scheme Observability -only-testing:ObservabilityTests/DashboardViewModelTests
```

### Visual Snapshot Tests

Snapshot tests verify UI components render correctly.

**Running Snapshot Tests:**
```bash
xcodebuild test -scheme Observability -only-testing:ObservabilityTests/SnapshotTests
```

### UI Tests

UI tests verify user interactions and flows.

**Running UI Tests:**
```bash
xcodebuild test -scheme Observability -only-testing:ObservabilityUITests
```

## iOS Features

### Haptic Feedback

The app provides haptic feedback for:
- **Critical Alerts**: Strong haptic feedback
- **Service Status Changes**: Different patterns for up/down/degraded
- **User Interactions**: Light feedback for taps and selections

**Implementation:**
```swift
HapticsManager.shared.playCriticalAlert()
HapticsManager.shared.playServiceDown()
```

### Push Notifications

Push notifications are sent for:
- Critical alerts
- Error alerts
- Warning alerts
- Service status changes

**Setup:**
1. Request authorization in `onAppear`
2. Register notification categories
3. Send notifications when alerts occur

**Configuration:**
- Critical alerts use `.critical` interruption level
- Error alerts use `.timeSensitive` interruption level
- Custom notification categories with actions

### Live Activities

Live Activities show real-time service metrics in:
- Dynamic Island (iPhone 14 Pro+)
- Lock Screen
- Notification Center

**Features:**
- Real-time CPU and memory usage
- Service status updates
- Automatic updates every 60 seconds
- Dismissal when service recovers

### Dynamic Island

Dynamic Island integration for iPhone 14 Pro+ devices.

**Features:**
- Critical service outages shown in Dynamic Island
- Compact and expanded views
- Real-time status updates
- Quick actions

## Deployment

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ / macOS 14.0+
- Swift 6.1+
- Apple Developer Account

### Build Configuration

1. **Set API Key**: Run `./scripts/setup-monitoring-api-key.sh`
2. **Generate Project**: Run `xcodegen generate`
3. **Configure Signing**: Set team and bundle identifier
4. **Build**: `xcodebuild build -scheme Observability`

### App Store Deployment

1. **Archive**: Product > Archive in Xcode
2. **Validate**: Validate archive in Organizer
3. **Upload**: Upload to App Store Connect
4. **Submit**: Submit for review

### Environment Variables

- `MONITORING_API_KEY`: API key for monitoring service
- `MONITORING_HTTP_URL`: HTTP endpoint URL
- `MONITORING_WEBSOCKET_URL`: WebSocket endpoint URL

## Troubleshooting

### Common Issues

#### Connection Failures
- Verify API key matches server configuration
- Check network connectivity
- Verify monitoring service is running

#### Push Notifications Not Working
- Check notification permissions in Settings
- Verify APNS certificate is configured
- Check device token registration

#### Live Activities Not Showing
- Verify Live Activities are enabled in Settings
- Check ActivityKit entitlement
- Ensure iOS 16.1+ for Live Activities

#### Tests Failing
- Clean build folder (Cmd+Shift+K)
- Reset package caches
- Verify test targets are properly configured

### Debugging

**Enable Debug Logging:**
```swift
#if DEBUG
print("Debug: \(message)")
#endif
```

**Network Debugging:**
- Use Charles Proxy or Proxyman
- Check WebSocket connection in Network inspector
- Verify SSE stream is receiving data

## Contributing

See `CONTRIBUTING.md` for contribution guidelines.

## License

MIT License - see LICENSE file for details.

---

*"The divine union of Swift's modern elegance and infrastructure's vital heartbeat"* ✨🎭

