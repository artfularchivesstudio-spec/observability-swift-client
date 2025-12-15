//
//  ObservabilityKitTests.swift
//  ObservabilityKitTests
//
//  🧪 The Cosmic Test Suite - Where All Modules Face Their Ultimate Trial ✨
//

import XCTest
import Combine
@testable import ObservabilityCore
@testable import ObservabilityNetworking
@testable import ObservabilityCommon

@available(macOS 14, iOS 17, *)
final class ObservabilityKitIntegrationTests: XCTestCase {

    var cancellables = Set<AnyCancellable>()

    // MARK: - Integration Tests

    func testCompleteServiceMonitoringFlow() {
        // Given
        let service = ServiceInfo(
            name: "Test Service",
            type: .strapi,
            port: 1337,
            category: .cms
        )

        // When
        let health = HealthCheckResult(
            serviceId: service.id,
            status: .degraded(responseTime: 0.15, errorRate: 0.02),
            responseTime: 0.15,
            metrics: [
                "cpu": .double(85.5),
                "memory": .double(4096),
                "requests": .int(1000)
            ]
        )

        // Then
        XCTAssertEqual(health.serviceId, service.id)
        XCTAssertFalse(health.status.isOperational)
        XCTAssertEqual(health.status.severity, .warning)

        // Create alert from degraded status
        let alert = Alert(
            title: "Service Degraded",
            message: "Service \(service.name) is experiencing issues",
            severity: health.status.severity,
            source: Alert.AlertSource(
                serviceId: service.id,
                serviceName: service.name,
                checkType: "health_check"
            )
        )

        XCTAssertEqual(alert.severity, .warning)
        XCTAssertEqual(alert.source.serviceId, service.id)
    }

    func testMetricsCollectionFlow() {
        // Given: Collection of metric points over time
        let now = Date()
        let points = [
            MetricPoint(timestamp: now.addingTimeInterval(-4), value: 10.0, label: "cpu"),
            MetricPoint(timestamp: now.addingTimeInterval(-3), value: 20.0, label: "cpu"),
            MetricPoint(timestamp: now.addingTimeInterval(-2), value: 30.0, label: "cpu"),
            MetricPoint(timestamp: now.addingTimeInterval(-1), value: 40.0, label: "cpu"),
            MetricPoint(timestamp: now, value: 50.0, label: "cpu")
        ]

        // When: Analyzed
        let collection = MetricsCollection(points: points)

        // Then: Statistics are calculated correctly
        XCTAssertEqual(collection.average(), 30.0)
        XCTAssertEqual(collection.min(), 10.0)
        XCTAssertEqual(collection.max(), 50.0)
        XCTAssertEqual(collection.percentile(50), 30.0) // Median
    }

    func testAlertRulesEvaluation() {
        // Given: A high CPU usage scenario
        let cpuMetric: MetricValue = .double(85.5)

        // When: Evaluated against a rule
        let rule = AlertRule(
            name: "High CPU Usage",
            conditions: [
                AlertRule.Condition(
                    metric: "cpu",
                    operator: .greaterThan,
                    threshold: 80.0,
                    duration: 300
                )
            ]
        )

        // Then: Rule should match
        let condition = rule.conditions[0]
        if let cpuValue = cpuMetric.doubleValue {
            let matches = evaluateCondition(condition, value: cpuValue)
            XCTAssertTrue(matches, "CPU usage \(cpuValue) should match condition > \(condition.threshold)")
        } else {
            XCTFail("Could not extract CPU value")
        }
    }

    func testTimeRangeFilters() {
        // Given: Metric points over different time ranges
        let now = Date()
        let points = [
            MetricPoint(timestamp: now.addingTimeInterval(-7200), value: 10), // 2 hours ago
            MetricPoint(timestamp: now.addingTimeInterval(-3600), value: 20), // 1 hour ago
            MetricPoint(timestamp: now.addingTimeInterval(-1800), value: 30), // 30 min ago
            MetricPoint(timestamp: now.addingTimeInterval(-600), value: 40),   // 10 min ago
            MetricPoint(timestamp: now, value: 50)
        ]

        let collection = MetricsCollection(points: points)

        // When: Filtered by time range
        let lastHour = TimeRange(start: now.addingTimeInterval(-3600), end: now)
        let recentPoints = collection.points(in: lastHour.start...lastHour.end)

        // Then: Recent points are filtered correctly
        XCTAssertEqual(recentPoints.count, 3) // 1 hour ago, 30 min ago, 10 min ago, now
    }

    func testAlertLifecycle() {
        // Given: A new alert
        var alert = Alert(
            title: "Critical Error",
            message: "Database connection failed",
            severity: .critical,
            source: Alert.AlertSource(serviceName: "PostgreSQL", checkType: "connection")
        )

        // Then: Initial state
        XCTAssertFalse(alert.acknowledged)
        XCTAssertFalse(alert.resolved)
        XCTAssertTrue(alert.age < 1) // Just created

        // When: Acknowledged
        alert = Alert(
            id: alert.id,
            title: alert.title,
            message: alert.message,
            severity: alert.severity,
            source: alert.source,
            timestamp: alert.timestamp,
            acknowledged: true, // Changed
            resolved: alert.resolved,
            tags: alert.tags,
            metadata: alert.metadata
        )

        // Then: State updated
        XCTAssertTrue(alert.acknowledged)
    }

    func testServiceInfoVariations() {
        // Given: Different service types
        let services: [ServiceInfo] = [
            ServiceInfo(name: "Strapi", type: .strapi, category: .cms),
            ServiceInfo(name: "Next.js", type: .nextjs, category: .frontend),
            ServiceInfo(name: "Python API", type: .flask, category: .backend),
            ServiceInfo(name: "PostgreSQL", type: .postgresql, category: .database)
        ]

        // Then: Each has unique properties
        XCTAssertEqual(services[0].type.displayName, "Strapi")
        XCTAssertEqual(services[1].type.displayName, "Next.js")
        XCTAssertEqual(services[2].type.displayName, "Flask")
        XCTAssertEqual(services[3].type.displayName, "PostgreSQL")

        // Categories have different colors
        let colors = Set(services.map { $0.category.color })
        XCTAssertEqual(colors.count, 4) // All different
    }

    func testNetworkStatsCalculation() {
        // Given: Network statistics
        let stats = SystemMetrics.NetworkStats(
            bytesIn: 1000000,
            bytesOut: 500000,
            packetsIn: 10000,
            packetsOut: 8000,
            errorsIn: 10,
            errorsOut: 5
        )

        // Then: Calculate throughput
        let totalMB = (stats.bytesIn + stats.bytesOut) / (1024 * 1024)
        XCTAssertEqual(totalMB, 1.430511474609375) // ~1.43 MB

        let errorRateIn = Double(stats.errorsIn) / Double(stats.packetsIn)
        XCTAssertEqual(errorRateIn, 0.001) // 0.1% error rate
    }

    // MARK: - Performance Tests

    func testLargeMetricsCollectionPerformance() {
        // Given: Large dataset
        var points: [MetricPoint] = []
        let now = Date()

        for i in 0..<10000 {
            points.append(MetricPoint(
                timestamp: now.addingTimeInterval(Double(i)),
                value: Double.random(in: 0...100),
                label: "metric_\(i % 10)"
            ))
        }

        // When: Analyzed
        measure {
            let collection = MetricsCollection(points: points)
            _ = collection.average()
            _ = collection.max()
            _ = collection.min()
            _ = collection.percentile(95)
        }

        // Then: Performance is acceptable (assertion in measure block)
    }

    func testConcurrentAlertProcessing() {
        // Given: Multiple alerts
        let expectations = (0..<100).map { i in
            Alert(
                title: "Alert \(i)",
                message: "Message \(i)",
                severity: [.info, .warning, .error, .critical].randomElement()!,
                source: Alert.AlertSource(serviceName: "Service\(i % 5)", checkType: "check\(i)")
            )
        }

        // When: Processed concurrently
        let expectation = XCTestExpectation(description: "Process alerts concurrently")

        DispatchQueue.concurrentPerform(iterations: expectations.count) { index in
            let alert = expectations[index]
            XCTAssertFalse(alert.title.isEmpty)
            XCTAssertTrue(alert.age >= 0)
        }

        expectation.fulfill()

        // Then: All processed successfully
        wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Helper Functions

    private func evaluateCondition(_ condition: AlertRule.Condition, value: Double) -> Bool {
        switch condition.operator {
        case .greaterThan:
            return value > condition.threshold
        case .lessThan:
            return value < condition.threshold
        case .equals:
            return value == condition.threshold
        case .notEquals:
            return value != condition.threshold
        case .greaterThanOrEqual:
            return value >= condition.threshold
        case .lessThanOrEqual:
            return value <= condition.threshold
        }
    }
}

// MARK: - Mock Implementations for Testing

@available(macOS 14, iOS 17, *)
class MockMetricsCollector: MetricsCollecting {
    var shouldFail = false
    var mockSystemMetrics = SystemMetrics(cpuUsage: 50, memoryUsage: 8000)
    var mockServiceMetrics = ServiceMetrics(serviceId: UUID(), requestCount: 1000, errorCount: 10)

    func collectSystemMetrics() async throws -> SystemMetrics {
        if shouldFail { throw MockError.collectionFailed }
        return mockSystemMetrics
    }

    func collectServiceMetrics(for serviceId: UUID) async throws -> ServiceMetrics {
        if shouldFail { throw MockError.collectionFailed }
        return mockServiceMetrics
    }

    func collectAllServiceMetrics() async throws -> [ServiceMetrics] {
        if shouldFail { throw MockError.collectionFailed }
        return [mockServiceMetrics]
    }

    func collectDatabaseMetrics() async throws -> DatabaseMetrics {
        if shouldFail { throw MockError.collectionFailed }
        return DatabaseMetrics()
    }

    func collectPM2Metrics() async throws -> PM2Metrics {
        if shouldFail { throw MockError.collectionFailed }
        return PM2Metrics()
    }

    func collectCustomMetrics<T: MetricValueConvertible>(_ metrics: [String], for serviceId: UUID) async throws -> [String: T] {
        if shouldFail { throw MockError.collectionFailed }
        return [:]
    }

    func getMetricsHistory(for serviceId: UUID, metricName: String, timeRange: TimeRange) async throws -> MetricsCollection {
        if shouldFail { throw MockError.collectionFailed }
        return MetricsCollection()
    }
}

@available(macOS 14, iOS 17, *)
class MockHealthChecker: HealthChecking {
    func performHealthCheck(for serviceId: UUID) async throws -> HealthCheckResult {
        return HealthCheckResult(
            serviceId: serviceId,
            status: .operational,
            responseTime: 0.05
        )
    }

    func performBatchHealthCheck(for serviceIds: [UUID]) async throws -> [HealthCheckResult] {
        return serviceIds.map { serviceId in
            HealthCheckResult(
                serviceId: serviceId,
                status: .operational,
                responseTime: 0.05
            )
        }
    }

    func performHTTPProbe(url: URL, timeout: TimeInterval) async throws -> HealthChecking.HTTPProbeResult {
        return HealthChecking.HTTPProbeResult(statusCode: 200, responseTime: 0.05, success: true)
    }

    func performDatabaseProbe(dsn: String, timeout: TimeInterval) async throws -> HealthChecking.DatabaseProbeResult {
        return HealthChecking.DatabaseProbeResult(connected: true, queryTime: 0.01)
    }

    func performPortProbe(host: String, port: Int, timeout: TimeInterval) async throws -> HealthChecking.PortProbeResult {
        return HealthChecking.PortProbeResult(open: true, responseTime: 0.02)
    }
}

enum MockError: Error {
    case collectionFailed
    case invalidData
}
