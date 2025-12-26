# 🎭✨ Observability Swift Client - iOS Infrastructure Monitoring ✨🎭

*"The divine union of Swift's modern elegance and infrastructure's vital heartbeat"*

## 🌟 Project Overview

A sophisticated iOS infrastructure monitoring application built with **Swift 6.1+**, **SwiftUI**, **Combine**, and **SwiftData**. This app provides real-time observability of your infrastructure services with beautiful, animated SwiftUI visualizations.

### 🎯 Key Features

- **Real-time Service Monitoring**: Live health checks and status updates via WebSocket
- **Beautiful SwiftUI Interface**: Smooth animations, gradients, and modern design patterns
- **Interactive Dashboard**: Service grid with tap-to-detail, live metrics, and alerts
- **Multi-Platform Support**: iOS, iPadOS, macOS, watchOS, and tvOS
- **Swift Package Architecture**: Modular design with clean separation of concerns

## 🏗️ Architecture

### ObservabilityKit Swift Package

The core functionality is provided through a modular Swift package with four main modules:

#### 1. **ObservabilityCore** 📦
Core data models and protocols for the monitoring system:
- `ServiceStatus` - Rich enum for service health states
- `ServiceInfo` - Complete service metadata
- `HealthCheckResult` - Health check with metrics
- `Alert` - Alert system with severity levels
- `Metrics` - System, service, and database metrics
- Protocols for metrics collection, health checking, and alert management

**Key Features:**
- Thread-safe with Swift actors and @Sendable types
- Full Codable support for JSON serialization
- Rich enums with associated values
- Protocol-oriented design for extensibility

#### 2. **ObservabilityNetworking** 🌐
Networking layer with modern Combine-based streams:
- `WebSocketCombineClient` - Real-time WebSocket with auto-reconnection
- `HTTPClient` - Async/await REST API client
- Event streaming with publishers for reactive updates
- Comprehensive error handling and recovery

**Key Features:**
- Combine framework integration
- Automatic reconnection strategies
- Multiple message type support
- Type-safe event handling

#### 3. **ObservabilityUI** 🎨
Beautiful SwiftUI components for data visualization:
- `ServiceStatusIndicator` - Animated service status circles
- `ServiceCard` - Interactive service cards with health data
- `ServiceGrid` - Adaptive grid layout
- `MetricChart` - Real-time line and area charts
- `MetricGauge` - Circular progress gauges
- `MetricsDashboard` - Combined metrics view
- `StatusFilterButton` - Filter controls

**Key Features:**
- Smooth animations and transitions
- Light/dark mode support
- Responsive design for all Apple platforms
- Xcode previews for all components

#### 4. **ObservabilityCommon** 🛠️
Shared utilities and extensions:
- Date formatting for human-readable timestamps
- Collection extensions for safe access and grouping
- String utilities and validations
- Color and styling helpers

## 💻 Installation

### Prerequisites

- Xcode 15.0+
- iOS 18.0+ / macOS 14.0+
- Swift 6.1+

### Setup

1. Clone the repository:
```bash
git clone https://github.com/artfularchivesstudio-spec/observability-swift-client.git
```

2. Generate the Xcode project (from the repo root) and open in Xcode:
```bash
cd observability-swift-client
xcodegen generate
open Observability.xcodeproj
```

3. Build and run:
- Select your target device/simulator
- Press Cmd+R to build and run

## 🚀 Usage

### Dashboard Overview

The main dashboard provides a comprehensive view of your infrastructure:

1. **Header Statistics** - Total services, healthy count, issues, and active alerts
2. **Status Filters** - Filter services by operational, degraded, down, or maintenance
3. **Service Grid** - Interactive cards showing service health and response times
4. **Live Metrics** - Real-time CPU and memory gauges with trend charts
5. **Recent Alerts** - Latest alerts with severity indicators

### Features

#### Real-Time Updates
- Services update their status every 10 seconds (simulated)
- Metrics stream in real-time with smooth animations
- WebSocket connection indicator shows live status

#### Interactive Elements
- Tap service cards for detailed information
- Filter services by status
- Responsive layouts adapt to device size

#### Visual Indicators
- Color-coded status indicators with pulse animations
- Severity-based alert icons and colors
- Gauge charts with gradient fills
- Real-time data point animations

## 🎯 Swift Package Details

### Target Structure

```
ObservabilityKit/
├── Sources/
│   ├── ObservabilityCore/
│   │   ├── Models/
│   │   │   ├── ServiceStatus.swift
│   │   │   ├── Alert.swift
│   │   │   └── Metrics.swift
│   │   └── Protocols/
│   │       └── MetricsCollecting.swift
│   │
│   ├── ObservabilityNetworking/
│   │   ├── WebSocketClientCombine.swift
│   │   └── HTTPClient.swift
│   │
│   ├── ObservabilityUI/
│   │   ├── Components/
│   │   │   ├── ServiceStatusIndicator.swift
│   │   │   ├── MetricChart.swift
│   │   │   └── Previews/
│   │   │       ├── ServiceStatusIndicator_Previews.swift
│   │   │       └── MetricChart_Previews.swift
│   │   └── PreviewContent/
│   │       └── PreviewData.swift
│   │
│   └── ObservabilityCommon/
│       └── Extensions/
│           ├── DateExtensions.swift
│           └── CollectionExtensions.swift
│
└── Tests/
    └── ObservabilityKitTests/
        └── (Testing targets for each module)
```

### Module Dependencies

```
ObservabilityKit
├── ObservabilityCommon (Base utilities)
├── ObservabilityCore (depends on Common)
├── ObservabilityNetworking (depends on Core)
└── ObservabilityUI (depends on Core)
```

## 🎨 UI Component Showcase

### Service Status Indicator
- Animated status circles with pulse effects
- Multiple status states: operational, degraded, down, maintenance, unknown
- Text labels or icon-only modes
- Smooth color transitions

### Service Cards
- Rich service information display
- Health check results with response times
- Port and type indicators
- Tap handling for navigation
- Loading states

### Metric Charts
- Real-time line and area charts
- Animated data point entry
- Statistics display (avg, min, max)
- Platform-adaptive sizing

### Metric Gauges
- Circular progress indicators
- Color-coded by value ranges
- Animated value changes
- Customizable ranges and units

### Combined Dashboard
- Complete monitoring interface
- Real-time updates across all components
- Responsive grid layouts
- Professional color schemes

## 📱 Platform Support

| Platform | Version | Status |
|----------|---------|--------|
| iOS | 18.0+ | ✅ Full Support |
| iPadOS | 18.0+ | ✅ Full Support |
| macOS | 14.0+ | ✅ Full Support |
| watchOS | 10.0+ | ⏳ Planned |
| tvOS | 17.0+ | ⏳ Planned |

**Platform-Specific Features:**
- **iOS**: Haptic feedback, Live Activities, Dynamic Island integration
- **macOS**: Full dashboard experience (iOS-only features gracefully disabled)
- **Cloud Services**: Special handling for cloud-hosted services (Supabase, etc.)

## 🧪 Testing

### Xcode Previews

All UI components include comprehensive Xcode previews for:
- Light and dark mode
- Different device sizes (iPhone SE, iPhone 15 Pro, iPad, macOS)
- Various states (loading, error, success)
- Interactive examples

### Preview Organization

Previews are located in:
- `/ObservabilityKit/Sources/ObservabilityUI/Components/Previews/`
- Individual preview files for each component
- Combined dashboard preview
- Preview data in `/ObservabilityKit/Sources/ObservabilityUI/PreviewContent/`

## 🛠️ Development

### Building the Package

```bash
cd ObservabilityKit
swift build
swift test
```

### Adding New Components

1. Create component in appropriate module
2. Add comprehensive Xcode previews
3. Include sample data in PreviewData.swift
4. Update documentation
5. Add tests

### SwiftUI Best Practices

- Use `@MainActor` for view models
- Implement proper state management with `@StateObject`
- Provide fallbacks for all async operations
- Include loading and error states
- Support dynamic type and accessibility

## 🎭 Theatrical Code Style

All code follows the Artful Archives Studio theatrical style:

```swift
/// 🌟 The Cosmic WebSocket Bridge - Where Real-Time Dreams Flow Through Digital Channels ✨
public actor WebSocketClient {
    // Implementation with dramatic flair and emojis
}
```

## 🔮 Future Enhancements

- [x] iOS/macOS platform adaptations (haptics, Live Activities conditional compilation)
- [x] Cloud service health check handling (Supabase, etc.)
- [x] Improved connection status and error handling
- [ ] Apple Watch companion app
- [ ] macOS menu bar extra
- [ ] Today widget for iOS
- [ ] Push notifications for critical alerts (code complete, needs testing)
- [ ] WatchOS complication support
- [ ] Deep linking to service details
- [ ] Export metrics data
- [ ] Integration with CloudKit for sync
- [ ] Siri shortcuts for common actions

## 🤝 Contributing

1. Maintain theatrical documentation style
2. Add Xcode previews for all UI changes
3. Test on multiple device sizes
4. Update relevant documentation
5. Follow Swift 6.1+ concurrency best practices

## 📄 License

MIT License - see LICENSE file for details

## 🌟 Acknowledgments

- Built with Swift 6.1+, SwiftUI, and Combine
- Inspired by modern reactive programming patterns
- Part of the Artful Archives Studio ecosystem
- Designed for infrastructure observability excellence

---

*"The divine union of Swift's modern elegance and infrastructure's vital heartbeat"* ✨🎭
