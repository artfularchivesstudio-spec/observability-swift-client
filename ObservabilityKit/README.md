# 🎭✨ ObservabilityKit - Swift Package for Infrastructure Monitoring ✨🎭

*"The cosmic bridge between Swift and your infrastructure's vital signs"*

## 🌟 Overview

ObservabilityKit is a modern Swift package that provides comprehensive infrastructure monitoring capabilities for iOS, macOS, watchOS, and tvOS applications. Built with Swift 6.1+ features including actors, async/await, and Combine, it offers real-time metrics collection, WebSocket streaming, and beautiful SwiftUI visualizations.

## 🎯 Features

### Core Module (`ObservabilityCore`)
- **Rich Data Types**: Service status enums, health check results, metrics models
- **Protocol-Based Architecture**: Clean abstractions for metrics collection, health checking, and alert management
- **Thread-Safe**: Built with Swift actors and Sendable types
- **Codable Support**: Easy JSON serialization/deserialization

### Networking Module (`ObservabilityNetworking`)
- **WebSocket Client**: Real-time streaming with automatic reconnection
- **HTTP Client**: Modern async/await REST API client
- **Combine Integration**: Reactive streams with publishers and subscribers
- **Error Handling**: Comprehensive error types and recovery strategies

### UI Module (`ObservabilityUI`)
- **SwiftUI Components**: Beautiful, reusable views for service status, metrics charts
- **Real-Time Charts**: Animated line, area, and gauge charts
- **Responsive Design**: Adaptive layouts for all Apple platforms
- **Theming Support**: Easy customization with colors and styles

### Common Module (`ObservabilityCommon`)
- **Date Extensions**: Human-readable time formatting
- **Collection Extensions**: Safe array access, grouping, chunking
- **Foundation Additions**: Common utilities shared across modules

## 🚀 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/artfularchivesstudio-spec/observability-swift-client.git", from: "1.0.0")
]
```

### Xcode Integration

1. In Xcode, select "Add Package Dependency"
2. Enter: `https://github.com/artfularchivesstudio-spec/observability-swift-client.git`
3. Select the modules you need (Core, Networking, UI, Common)

## 💡 Quick Start

### 1. Connect to Monitoring Service

```swift
import ObservabilityNetworking
import Combine

@MainActor
class MonitoringViewModel: ObservableObject {
    private let webSocketClient = WebSocketCombineClient()
    private var cancellables = Set<AnyCancellable>()

    @Published var isConnected = false
    @Published var metrics: [MetricPoint] = []

    func connect() {
        guard let url = URL(string: "wss://api-router.cloud/monitoring/custom/") else { return }

        Task {
            try await webSocketClient.connect(to: url)
            isConnected = true

            // Subscribe to metrics
            webSocketClient.metricPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] metric in
                    self?.metrics.append(metric)
                }
                .store(in: &cancellables)
        }
    }
}
```

### 2. Display Service Status

```swift
import SwiftUI
import ObservabilityUI

struct ServiceDashboard: View {
    let services: [ServiceInfo]
    let healthResults: [UUID: HealthCheckResult]

    var body: some View {
        ScrollView {
            ServiceGrid(
                services: services,
                healthResults: healthResults
            ) { service in
                // Handle service tap
            }
        }
    }
}
```

### 3. Show Real-Time Metrics Chart

```swift
struct MetricsView: View {
    @StateObject private var viewModel = MetricsViewModel()

    var body: some View {
        MetricChart(
            title: "CPU Usage",
            metricsPublisher: viewModel.cpuMetricsPublisher,
            chartType: .line
        )
    }
}
```

## 🎨 Usage Examples

### Service Status Display

```swift
struct ServiceStatusView: View {
    let service: ServiceInfo
    let health: HealthCheckResult

    var body: some View {
        VStack {
            ServiceStatusIndicator(status: health.status)

            Text(service.name)
                .font(.headline)

            Text("Response: \(Int(health.responseTime * 1000))ms")
                .font(.caption)
        }
    }
}
```

### Alert Management

```swift
class AlertManager: ObservableObject {
    @Published var alerts: [Alert] = []

    func handleNewAlert(_ alert: Alert) {
        if alert.severity == .critical {
            // Critical alert handling
            showCriticalAlert(alert)
        }
        alerts.append(alert)
    }

    func showCriticalAlert(_ alert: Alert) {
        // Implement critical alert UI
    }
}
```

### Health Check Monitoring

```swift
actor HealthMonitor {
    private let healthChecker = HTTPHealthChecker()

    func monitorService(_ service: ServiceInfo) async throws -> HealthCheckResult {
        guard let url = service.baseURL else {
            throw HealthCheckError.invalidURL
        }

        return try await healthChecker.performHealthCheck(for: service.id)
    }
}
```

## 🎭 Theatrical Documentation Style

All code follows the theatrical documentation style with emojis and poetic descriptions:

```swift
/// 🌟 The Cosmic WebSocket Bridge - Where Real-Time Dreams Flow Through Digital Channels ✨
public actor WebSocketClient {
    // Implementation with dramatic flair
}
```

## 📱 Platform Support

- **iOS 17.0+** / **iPadOS 17.0+**
- **macOS 14.0+**
- **watchOS 10.0+**
- **tvOS 17.0+**
- **Swift 6.1+**

## 🛠️ Development

### Building the Package

```bash
cd ObservabilityKit
swift build
swift test
```

### Running Tests

```bash
swift test --parallel
xcodebuild test -scheme ObservabilityKit
```

## 🎪 Module Architecture

```
ObservabilityKit/
├── ObservabilityCore/          # Core data types and protocols
│   ├── Models/
│   │   ├── ServiceStatus.swift
│   │   ├── Alert.swift
│   │   └── Metrics.swift
│   └── Protocols/
│       └── MetricsCollecting.swift
│
├── ObservabilityNetworking/    # Network clients
│   ├── WebSocketClientCombine.swift
│   └── HTTPClient.swift
│
├── ObservabilityUI/            # SwiftUI components
│   └── Components/
│       ├── ServiceStatusIndicator.swift
│       └── MetricChart.swift
│
└── ObservabilityCommon/        # Shared utilities
    └── Extensions/
        ├── DateExtensions.swift
        └── CollectionExtensions.swift
```

## 🔮 Advanced Features

### Custom Alert Rules

```swift
let highCPURule = AlertRule(
    name: "High CPU Usage",
    conditions: [
        .init(metric: "cpu_usage", operator: .greaterThan, threshold: 80, duration: 300)
    ],
    actions: [
        .sendAlert(Alert(
            title: "High CPU Usage",
            message: "CPU usage exceeds 80% for 5 minutes",
            severity: .warning,
            source: AlertSource(serviceName: "web-server")
        ))
    ]
)
```

### WebSocket Reconnection Strategy

```swift
let client = WebSocketCombineClient()
client.eventPublisher
    .filter { $0.type == "connection" }
    .sink { event in
        if event.data["status"] == "disconnected" {
            // Auto-reconnect logic
            Task { try await client.connect(to: endpoint) }
        }
    }
    .store(in: &cancellables)
```

### Custom Metrics Collection

```swift
struct CustomMetricsCollector: MetricsCollecting {
    func collectSystemMetrics() async throws -> SystemMetrics {
        // Custom system monitoring logic
    }

    func collectServiceMetrics(for serviceId: UUID) async throws -> ServiceMetrics {
        // Custom service monitoring
    }
}
```

## 🤝 Contributing

1. Follow the theatrical documentation style
2. Use Swift 6.1+ concurrency features
3. Write comprehensive tests
4. Update documentation for new features

## 📄 License

MIT License - see LICENSE file for details

## 🌟 Acknowledgments

- Built with Swift 6.1+ and Combine framework
- Inspired by modern reactive programming patterns
- Designed for the Artful Archives Studio ecosystem

---

*"The cosmic bridge between Swift and your infrastructure's vital signs"* ✨🎭
