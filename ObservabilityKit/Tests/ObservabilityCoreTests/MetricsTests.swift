//
//  MetricsTests.swift
//  ObservabilityCoreTests
//
//  📊 The Cosmic Metrics Validator - Where Numbers Face Mathematical Scrutiny ✨
//

import XCTest
import ObservabilityCore

@available(macOS 14, iOS 17, *)
final class MetricsTests: XCTestCase {

    // MARK: - System Metrics Tests

    func testSystemMetricsInitialization() {
        let networkStats = SystemMetrics.NetworkStats(
            bytesIn: 1024.5,
            bytesOut: 2048.0,
            packetsIn: 100,
            packetsOut: 200,
            errorsIn: 2,
            errorsOut: 1
        )

        let metrics = SystemMetrics(
            timestamp: Date(),
            cpuUsage: 45.5,
            memoryUsage: 8192.0,
            memoryTotal: 16000.0,
            diskUsage: 250.0,
            diskTotal: 500.0,
            loadAverage: [1.5, 1.8, 2.0],
            networkStats: networkStats
        )

        XCTAssertEqual(metrics.cpuUsage, 45.5)
        XCTAssertEqual(metrics.memoryUsage, 8192.0)
        XCTAssertEqual(metrics.memoryTotal, 16000.0)
        XCTAssertEqual(metrics.diskUsage, 250.0)
        XCTAssertEqual(metrics.diskTotal, 500.0)
        XCTAssertEqual(metrics.loadAverage.count, 3)
        XCTAssertEqual(metrics.networkStats.bytesIn, 1024.5)
    }

    func testSystemMetricsMemoryPercentage() {
        let metrics = SystemMetrics(
            memoryUsage: 8000,
            memoryTotal: 16000
        )

        XCTAssertEqual(metrics.memoryPercentage, 50.0)
    }

    func testSystemMetricsMemoryPercentageZeroTotal() {
        let metrics = SystemMetrics(
            memoryUsage: 8000,
            memoryTotal: 0
        )

        XCTAssertEqual(metrics.memoryPercentage, 0)
    }

    func testSystemMetricsDiskPercentage() {
        let metrics = SystemMetrics(
            diskUsage: 250,
            diskTotal: 500
        )

        XCTAssertEqual(metrics.diskPercentage, 50.0)
    }

    func testSystemMetricsDiskPercentageZeroTotal() {
        let metrics = SystemMetrics(
            diskUsage: 250,
            diskTotal: 0
        )

        XCTAssertEqual(metrics.diskPercentage, 0)
    }

    // MARK: - Network Stats Tests

    func testNetworkStatsInitialization() {
        let stats = SystemMetrics.NetworkStats(
            bytesIn: 1000.5,
            bytesOut: 2000.75,
            packetsIn: 50,
            packetsOut: 75,
            errorsIn: 1,
            errorsOut: 2
        )

        XCTAssertEqual(stats.bytesIn, 1000.5)
        XCTAssertEqual(stats.bytesOut, 2000.75)
        XCTAssertEqual(stats.packetsIn, 50)
        XCTAssertEqual(stats.packetsOut, 75)
        XCTAssertEqual(stats.errorsIn, 1)
        XCTAssertEqual(stats.errorsOut, 2)
    }

    // MARK: - Service Metrics Tests

    func testServiceMetricsInitialization() {
        let serviceId = UUID()
        let metrics = ServiceMetrics(
            serviceId: serviceId,
            timestamp: Date(),
            uptime: 86400,
            requestCount: 10000,
            errorCount: 50,
            responseTimeP50: 0.05,
            responseTimeP95: 0.15,
            responseTimeP99: 0.25,
            activeConnections: 150,
            queuedRequests: 10
        )

        XCTAssertEqual(metrics.serviceId, serviceId)
        XCTAssertEqual(metrics.uptime, 86400)
        XCTAssertEqual(metrics.requestCount, 10000)
        XCTAssertEqual(metrics.errorCount, 50)
        XCTAssertEqual(metrics.responseTimeP50, 0.05)
        XCTAssertEqual(metrics.responseTimeP99, 0.25)
        XCTAssertEqual(metrics.activeConnections, 150)
    }

    func testServiceMetricsErrorRate() {
        let metrics = ServiceMetrics(
            requestCount: 10000,
            errorCount: 100
        )

        XCTAssertEqual(metrics.errorRate, 0.01)
    }

    func testServiceMetricsErrorRateZeroRequests() {
        let metrics = ServiceMetrics(
            requestCount: 0,
            errorCount: 0
        )

        XCTAssertEqual(metrics.errorRate, 0)
    }

    func testServiceMetricsRequestsPerSecond() {
        let metrics = ServiceMetrics(
            uptime: 3600,
            requestCount: 7200
        )

        XCTAssertEqual(metrics.requestsPerSecond, 2.0)
    }

    func testServiceMetricsRequestsPerSecondZeroUptime() {
        let metrics = ServiceMetrics(
            uptime: 0,
            requestCount: 100
        )

        XCTAssertEqual(metrics.requestsPerSecond, 0)
    }

    // MARK: - Database Metrics Tests

    func testDatabaseMetricsInitialization() {
        let tableStats = DatabaseMetrics.TableStats(
            tableName: "users",
            rowCount: 10000,
            sizeBytes: 1048576,
            sequentialScans: 50,
            indexScans: 1000
        )

        let slowQuery = DatabaseMetrics.SlowQuery(
            query: "SELECT * FROM users WHERE age > ?",
            duration: 5.5,
            timestamp: Date(),
            parameters: ["18"]
        )

        let metrics = DatabaseMetrics(
            timestamp: Date(),
            activeConnections: 25,
            idleConnections: 5,
            waitingConnections: 2,
            transactionsPerSecond: 150.5,
            cacheHitRate: 0.95,
            indexHitRate: 0.98,
            tableStats: ["users": tableStats],
            slowQueries: [slowQuery]
        )

        XCTAssertEqual(metrics.activeConnections, 25)
        XCTAssertEqual(metrics.idleConnections, 5)
        XCTAssertEqual(metrics.transactionsPerSecond, 150.5)
        XCTAssertEqual(metrics.cacheHitRate, 0.95)
        XCTAssertEqual(metrics.tableStats["users"]?.rowCount, 10000)
        XCTAssertEqual(metrics.slowQueries.count, 1)
    }

    func testTableStatsInitialization() {
        let stats = DatabaseMetrics.TableStats(
            tableName: "orders",
            rowCount: 50000,
            sizeBytes: 2097152,
            sequentialScans: 100,
            indexScans: 5000
        )

        XCTAssertEqual(stats.tableName, "orders")
        XCTAssertEqual(stats.rowCount, 50000)
        XCTAssertEqual(stats.sizeBytes, 2097152)
        XCTAssertEqual(stats.sequentialScans, 100)
        XCTAssertEqual(stats.indexScans, 5000)
    }

    func testSlowQueryInitialization() {
        let query = DatabaseMetrics.SlowQuery(
            query: "SELECT COUNT(*) FROM large_table",
            duration: 10.2,
            timestamp: Date(),
            parameters: ["param1", "param2"]
        )

        XCTAssertEqual(query.query, "SELECT COUNT(*) FROM large_table")
        XCTAssertEqual(query.duration, 10.2)
        XCTAssertNotNil(query.parameters)
        XCTAssertEqual(query.parameters?.count, 2)
    }

    func testSlowQueryWithoutParameters() {
        let query = DatabaseMetrics.SlowQuery(
            query: "SELECT 1",
            duration: 1.0,
            timestamp: Date()
        )

        XCTAssertNil(query.parameters)
    }

    // MARK: - PM2 Metrics Tests

    func testPM2MetricsInitialization() {
        let process = PM2Metrics.ProcessInfo(
            id: "web-server-0",
            name: "web-server",
            pid: 12345,
            status: "online",
            uptime: 86400,
            restarts: 2,
            cpu: 45.5,
            memory: 2048.0,
            watching: true
        )

        let metrics = PM2Metrics(
            timestamp: Date(),
            processes: [process],
            totalProcesses: 1,
            runningProcesses: 1,
            erroredProcesses: 0,
            stoppedProcesses: 0,
            totalRestarts: 2,
            totalUptime: 86400
        )

        XCTAssertEqual(metrics.totalProcesses, 1)
        XCTAssertEqual(metrics.runningProcesses, 1)
        XCTAssertEqual(metrics.erroredProcesses, 0)
        XCTAssertEqual(metrics.totalRestarts, 2)
    }

    func testProcessInfoInitialization() {
        let process = PM2Metrics.ProcessInfo(
            id: "api-server-0",
            name: "api-server",
            pid: 67890,
            status: "online",
            uptime: 43200,
            restarts: 1,
            cpu: 30.0,
            memory: 1024.0,
            watching: false
        )

        XCTAssertEqual(process.id, "api-server-0")
        XCTAssertEqual(process.name, "api-server")
        XCTAssertEqual(process.pid, 67890)
        XCTAssertEqual(process.status, "online")
        XCTAssertEqual(process.uptime, 43200)
        XCTAssertEqual(process.cpu, 30.0)
    }

    // MARK: - Metric Point Tests

    func testMetricPointInitialization() {
        let point = MetricPoint(
            timestamp: Date(),
            value: 42.5,
            label: "cpu_usage",
            tags: ["host": "server1", "region": "us-east"]
        )

        XCTAssertEqual(point.value, 42.5)
        XCTAssertEqual(point.label, "cpu_usage")
        XCTAssertEqual(point.tags["host"], "server1")
        XCTAssertEqual(point.tags["region"], "us-east")
    }

    func testMetricPointWithoutLabel() {
        let point = MetricPoint(
            value: 100.0,
            tags: [:]
        )

        XCTAssertEqual(point.value, 100.0)
        XCTAssertNil(point.label)
        XCTAssertTrue(point.tags.isEmpty)
    }

    // MARK: - Metrics Collection Tests

    func testMetricsCollectionInitialization() {
        let points = [
            MetricPoint(value: 10.0, timestamp: Date().addingTimeInterval(-2)),
            MetricPoint(value: 20.0, timestamp: Date().addingTimeInterval(-1)),
            MetricPoint(value: 30.0, timestamp: Date())
        ]

        let collection = MetricsCollection(points: points)

        XCTAssertEqual(collection.points.count, 3)
        // Points should be sorted by timestamp
        XCTAssertEqual(collection.points.first?.value, 10.0)
        XCTAssertEqual(collection.points.last?.value, 30.0)
    }

    func testMetricsCollectionInTimeRange() {
        let now = Date()
        let points = [
            MetricPoint(value: 10.0, timestamp: now.addingTimeInterval(-3)),
            MetricPoint(value: 20.0, timestamp: now.addingTimeInterval(-2)),
            MetricPoint(value: 30.0, timestamp: now.addingTimeInterval(-1)),
            MetricPoint(value: 40.0, timestamp: now)
        ]

        let collection = MetricsCollection(points: points)
        let range = now.addingTimeInterval(-2.5)...now.addingTimeInterval(-0.5)
        let filtered = collection.points(in: range)

        XCTAssertEqual(filtered.count, 2)
        XCTAssertEqual(filtered.first?.value, 20.0)
        XCTAssertEqual(filtered.last?.value, 30.0)
    }

    func testMetricsCollectionAverage() {
        let points = [
            MetricPoint(value: 10.0),
            MetricPoint(value: 20.0),
            MetricPoint(value: 30.0),
            MetricPoint(value: 40.0)
        ]

        let collection = MetricsCollection(points: points)
        XCTAssertEqual(collection.average(), 25.0)
    }

    func testMetricsCollectionAverageEmpty() {
        let collection = MetricsCollection()
        XCTAssertEqual(collection.average(), 0)
    }

    func testMetricsCollectionMax() {
        let points = [
            MetricPoint(value: 10.0),
            MetricPoint(value: 5.0),
            MetricPoint(value: 30.0),
            MetricPoint(value: 20.0)
        ]

        let collection = MetricsCollection(points: points)
        XCTAssertEqual(collection.max(), 30.0)
    }

    func testMetricsCollectionMaxEmpty() {
        let collection = MetricsCollection()
        XCTAssertNil(collection.max())
    }

    func testMetricsCollectionMin() {
        let points = [
            MetricPoint(value: 10.0),
            MetricPoint(value: 5.0),
            MetricPoint(value: 30.0),
            MetricPoint(value: 20.0)
        ]

        let collection = MetricsCollection(points: points)
        XCTAssertEqual(collection.min(), 5.0)
    }

    func testMetricsCollectionMinEmpty() {
        let collection = MetricsCollection()
        XCTAssertNil(collection.min())
    }

    func testMetricsCollectionPercentile() {
        let points = (0..<100).map { MetricPoint(value: Double($0)) }
        let collection = MetricsCollection(points: points)

        XCTAssertEqual(collection.percentile(0), 0.0)   // Min
        XCTAssertEqual(collection.percentile(50), 49.5) // Median
        XCTAssertEqual(collection.percentile(100), 99.0) // Max
    }

    func testMetricsCollectionPercentileEmpty() {
        let collection = MetricsCollection()
        XCTAssertEqual(collection.percentile(50), 0)
    }
}
