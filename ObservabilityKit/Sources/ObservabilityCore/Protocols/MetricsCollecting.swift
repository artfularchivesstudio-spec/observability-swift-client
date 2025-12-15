//
//  MetricsCollecting.swift
//  ObservabilityCore
//
//  🎯 The Cosmic Metrics Collector Protocol - Where Performance Becomes Observable ✨
//

import Foundation

/// 🎯 Protocol for collecting metrics from various sources
@available(macOS 14, iOS 17, *)
public protocol MetricsCollecting: Sendable {
    // MARK: - System Metrics
    func collectSystemMetrics() async throws -> SystemMetrics

    // MARK: - Service Metrics
    func collectServiceMetrics(for serviceId: UUID) async throws -> ServiceMetrics
    func collectAllServiceMetrics() async throws -> [ServiceMetrics]

    // MARK: - Database Metrics
    func collectDatabaseMetrics() async throws -> DatabaseMetrics

    // MARK: - PM2 Metrics
    func collectPM2Metrics() async throws -> PM2Metrics

    // MARK: - Custom Metrics
    func collectCustomMetrics<T: MetricValueConvertible>(
        _ metrics: [String],
        for serviceId: UUID
    ) async throws -> [String: T]

    // MARK: - Historical Data
    func getMetricsHistory(
        for serviceId: UUID,
        metricName: String,
        timeRange: TimeRange
    ) async throws -> MetricsCollection
}

/// 🔔 Protocol for health checking
@available(macOS 14, iOS 17, *)
public protocol HealthChecking: Sendable {
    // MARK: - Health Checks
    func performHealthCheck(for serviceId: UUID) async throws -> HealthCheckResult
    func performBatchHealthCheck(for serviceIds: [UUID]) async throws -> [HealthCheckResult]

    // MARK: - Probe Types
    func performHTTPProbe(
        url: URL,
        timeout: TimeInterval
    ) async throws -> HTTPProbeResult

    func performDatabaseProbe(
        dsn: String,
        timeout: TimeInterval
    ) async throws -> DatabaseProbeResult

    func performPortProbe(
        host: String,
        port: Int,
        timeout: TimeInterval
    ) async throws -> PortProbeResult

    // MARK: - Probe Results
    struct HTTPProbeResult: Sendable, Codable {
        public let statusCode: Int
        public let responseTime: TimeInterval
        public let success: Bool
        public let bodySize: Int
        public let headers: [String: String]

        public init(
            statusCode: Int = 0,
            responseTime: TimeInterval = 0,
            success: Bool = false,
            bodySize: Int = 0,
            headers: [String: String] = [:]
        ) {
            self.statusCode = statusCode
            self.responseTime = responseTime
            self.success = success
            self.bodySize = bodySize
            self.headers = headers
        }
    }

    struct DatabaseProbeResult: Sendable, Codable {
        public let connected: Bool
        public let queryTime: TimeInterval
        public let error: String?

        public init(
            connected: Bool = false,
            queryTime: TimeInterval = 0,
            error: String? = nil
        ) {
            self.connected = connected
            self.queryTime = queryTime
            self.error = error
        }
    }

    struct PortProbeResult: Sendable, Codable {
        public let open: Bool
        public let responseTime: TimeInterval

        public init(
            open: Bool = false,
            responseTime: TimeInterval = 0
        ) {
            self.open = open
            self.responseTime = responseTime
        }
    }
}

/// 🚨 Protocol for alert management
@available(macOS 14, iOS 17, *)
public protocol AlertManaging: Sendable {
    // MARK: - Alert Operations
    func createAlert(_ alert: Alert) async throws
    func acknowledgeAlert(_ alertId: UUID) async throws
    func resolveAlert(_ alertId: UUID) async throws
    func deleteAlert(_ alertId: UUID) async throws

    // MARK: - Alert Queries
    func getAlert(_ alertId: UUID) async throws -> Alert?
    func getActiveAlerts() async throws -> [Alert]
    func getAlertsBySeverity(_ severity: AlertSeverity) async throws -> [Alert]
    func getAlertsByService(_ serviceId: UUID) async throws -> [Alert]
    func getAlertStats() async throws -> AlertStats

    // MARK: - Notification Management
    func sendNotification(for alert: Alert) async throws
    func updateNotificationPreferences(_ preferences: NotificationPreferences) async throws
    func getNotificationPreferences() async throws -> NotificationPreferences

    // MARK: - Alert Rules
    func addAlertRule(_ rule: AlertRule) async throws
    func removeAlertRule(_ ruleId: UUID) async throws
    func evaluateRules(for metrics: [String: MetricValue]) async throws -> [Alert]
}

/// 🔔 Protocol for event/stream management
@available(macOS 14, iOS 17, *)
public protocol EventStreaming: Sendable {
    // MARK: - Stream Management
    func connect(to endpoint: URL) async throws
    func disconnect() async throws
    var isConnected: Bool { get }

    // MARK: - Event Handling
    func subscribe(to eventTypes: [String]) async throws
    func unsubscribe(from eventTypes: [String]) async throws

    // MARK: - Event Publishing
    func sendEvent(_ event: StreamEvent) async throws
    func publishMetrics(_ metrics: [String: MetricValue]) async throws
    func broadcastHealthUpdate(_ result: HealthCheckResult) async throws

    // MARK: - Event Stream
    var eventStream: AsyncStream<StreamEvent> { get }
    var metricStream: AsyncStream<MetricPoint> { get }
    var healthStream: AsyncStream<HealthCheckResult> { get }
}

/// 📊 Metric value conversion protocol
@available(macOS 14, iOS 17, *)
public protocol MetricValueConvertible {
    func toMetricValue() -> MetricValue
}

extension Int: MetricValueConvertible {
    public func toMetricValue() -> MetricValue { .int(self) }
}

extension Double: MetricValueConvertible {
    public func toMetricValue() -> MetricValue { .double(self) }
}

extension String: MetricValueConvertible {
    public func toMetricValue() -> MetricValue { .string(self) }
}

extension Bool: MetricValueConvertible {
    public func toMetricValue() -> MetricValue { .bool(self) }
}

// MARK: - Supporting Types

@available(macOS 14, iOS 17, *)
public struct TimeRange: Sendable, Codable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    public static var lastHour: TimeRange {
        let end = Date()
        let start = end.addingTimeInterval(-3600)
        return TimeRange(start: start, end: end)
    }

    public static var last24Hours: TimeRange {
        let end = Date()
        let start = end.addingTimeInterval(-86400)
        return TimeRange(start: start, end: end)
    }

    public static var last7Days: TimeRange {
        let end = Date()
        let start = end.addingTimeInterval(-604800)
        return TimeRange(start: start, end: end)
    }
}

@available(macOS 14, iOS 17, *)
public struct StreamEvent: Sendable, Codable {
    public let id: UUID
    public let type: String
    public let timestamp: Date
    public let data: [String: String]
    public let source: String

    public init(
        id: UUID = UUID(),
        type: String,
        timestamp: Date = Date(),
        data: [String: String] = [:],
        source: String
    ) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.data = data
        self.source = source
    }
}

@available(macOS 14, iOS 17, *)
public struct AlertRule: Sendable, Codable {
    public let id: UUID
    public var name: String
    public var enabled: Bool
    public var conditions: [Condition]
    public var actions: [Action]

    public init(
        id: UUID = UUID(),
        name: String,
        enabled: Bool = true,
        conditions: [Condition] = [],
        actions: [Action] = []
    ) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.conditions = conditions
        self.actions = actions
    }

    public struct Condition: Sendable, Codable {
        public let metric: String
        public let operator: Operator
        public let threshold: Double
        public let duration: TimeInterval?

        public enum `Operator`: String, Sendable, Codable {
            case greaterThan = "gt"
            case lessThan = "lt"
            case equals = "eq"
            case notEquals = "neq"
            case greaterThanOrEqual = "gte"
            case lessThanOrEqual = "lte"
        }
    }

    public enum Action: Sendable, Codable {
        case sendAlert(Alert)
        case webhook(url: URL, payload: [String: String])
        case log(severity: String, message: String)
        case execute(String)
    }
}
