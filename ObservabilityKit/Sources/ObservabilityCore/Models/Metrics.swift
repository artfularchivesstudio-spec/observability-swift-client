//
//  Metrics.swift
//  ObservabilityCore
//
//  📊 The Cosmic Metrics Collection - Where Quantified Observations Illuminate Digital Reality ✨
//

import Foundation

/// 📈 System metrics representing resource usage
@available(macOS 14, iOS 17, *)
public struct SystemMetrics: Sendable, Codable {
    public let timestamp: Date
    public let cpuUsage: Double
    public let memoryUsage: Double
    public let memoryTotal: Double
    public let diskUsage: Double
    public let diskTotal: Double
    public let loadAverage: [Double]
    public let networkStats: NetworkStats

    public init(
        timestamp: Date = Date(),
        cpuUsage: Double = 0,
        memoryUsage: Double = 0,
        memoryTotal: Double = 0,
        diskUsage: Double = 0,
        diskTotal: Double = 0,
        loadAverage: [Double] = [],
        networkStats: NetworkStats = NetworkStats()
    ) {
        self.timestamp = timestamp
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.memoryTotal = memoryTotal
        self.diskUsage = diskUsage
        self.diskTotal = diskTotal
        self.loadAverage = loadAverage
        self.networkStats = networkStats
    }

    public struct NetworkStats: Sendable, Codable {
        public let bytesIn: Double
        public let bytesOut: Double
        public let packetsIn: Int
        public let packetsOut: Int
        public let errorsIn: Int
        public let errorsOut: Int

        public init(
            bytesIn: Double = 0,
            bytesOut: Double = 0,
            packetsIn: Int = 0,
            packetsOut: Int = 0,
            errorsIn: Int = 0,
            errorsOut: Int = 0
        ) {
            self.bytesIn = bytesIn
            self.bytesOut = bytesOut
            self.packetsIn = packetsIn
            self.packetsOut = packetsOut
            self.errorsIn = errorsIn
            self.errorsOut = errorsOut
        }
    }

    public var memoryPercentage: Double {
        guard memoryTotal > 0 else { return 0 }
        return (memoryUsage / memoryTotal) * 100
    }

    public var diskPercentage: Double {
        guard diskTotal > 0 else { return 0 }
        return (diskUsage / diskTotal) * 100
    }
}

/// 🌐 Service-specific metrics
@available(macOS 14, iOS 17, *)
public struct ServiceMetrics: Sendable, Codable {
    public let serviceId: UUID
    public let timestamp: Date
    public let uptime: TimeInterval
    public let requestCount: Int
    public let errorCount: Int
    public let responseTimeP50: TimeInterval
    public let responseTimeP95: TimeInterval
    public let responseTimeP99: TimeInterval
    public let activeConnections: Int
    public let queuedRequests: Int

    public init(
        serviceId: UUID,
        timestamp: Date = Date(),
        uptime: TimeInterval = 0,
        requestCount: Int = 0,
        errorCount: Int = 0,
        responseTimeP50: TimeInterval = 0,
        responseTimeP95: TimeInterval = 0,
        responseTimeP99: TimeInterval = 0,
        activeConnections: Int = 0,
        queuedRequests: Int = 0
    ) {
        self.serviceId = serviceId
        self.timestamp = timestamp
        self.uptime = uptime
        self.requestCount = requestCount
        self.errorCount = errorCount
        self.responseTimeP50 = responseTimeP50
        self.responseTimeP95 = responseTimeP95
        self.responseTimeP99 = responseTimeP99
        self.activeConnections = activeConnections
        self.queuedRequests = queuedRequests
    }

    public var errorRate: Double {
        guard requestCount > 0 else { return 0 }
        return Double(errorCount) / Double(requestCount)
    }

    public var requestsPerSecond: Double {
        guard uptime > 0 else { return 0 }
        return Double(requestCount) / uptime
    }
}

/// 🗄️ Database metrics
@available(macOS 14, iOS 17, *)
public struct DatabaseMetrics: Sendable, Codable {
    public let timestamp: Date
    public let activeConnections: Int
    public let idleConnections: Int
    public let waitingConnections: Int
    public let transactionsPerSecond: Double
    public let cacheHitRate: Double
    public let indexHitRate: Double
    public let tableStats: [String: TableStats]
    public let slowQueries: [SlowQuery]

    public init(
        timestamp: Date = Date(),
        activeConnections: Int = 0,
        idleConnections: Int = 0,
        waitingConnections: Int = 0,
        transactionsPerSecond: Double = 0,
        cacheHitRate: Double = 0,
        indexHitRate: Double = 0,
        tableStats: [String: TableStats] = [:],
        slowQueries: [SlowQuery] = []
    ) {
        self.timestamp = timestamp
        self.activeConnections = activeConnections
        self.idleConnections = idleConnections
        self.waitingConnections = waitingConnections
        self.transactionsPerSecond = transactionsPerSecond
        self.cacheHitRate = cacheHitRate
        self.indexHitRate = indexHitRate
        self.tableStats = tableStats
        self.slowQueries = slowQueries
    }

    public struct TableStats: Sendable, Codable {
        public let tableName: String
        public let rowCount: Int
        public let sizeBytes: Int
        public let sequentialScans: Int
        public let indexScans: Int

        public init(
            tableName: String,
            rowCount: Int = 0,
            sizeBytes: Int = 0,
            sequentialScans: Int = 0,
            indexScans: Int = 0
        ) {
            self.tableName = tableName
            self.rowCount = rowCount
            self.sizeBytes = sizeBytes
            self.sequentialScans = sequentialScans
            self.indexScans = indexScans
        }
    }

    public struct SlowQuery: Sendable, Codable, Identifiable {
        public let id: UUID
        public let query: String
        public let duration: TimeInterval
        public let timestamp: Date
        public let parameters: [String]?

        public init(
            id: UUID = UUID(),
            query: String,
            duration: TimeInterval,
            timestamp: Date,
            parameters: [String]? = nil
        ) {
            self.id = id
            self.query = query
            self.duration = duration
            self.timestamp = timestamp
            self.parameters = parameters
        }
    }
}

/// 📦 PM2 process metrics
@available(macOS 14, iOS 17, *)
public struct PM2Metrics: Sendable, Codable {
    public let timestamp: Date
    public let processes: [ProcessInfo]
    public let totalProcesses: Int
    public let runningProcesses: Int
    public let erroredProcesses: Int
    public let stoppedProcesses: Int
    public let totalRestarts: Int
    public let totalUptime: TimeInterval

    public init(
        timestamp: Date = Date(),
        processes: [ProcessInfo] = [],
        totalProcesses: Int = 0,
        runningProcesses: Int = 0,
        erroredProcesses: Int = 0,
        stoppedProcesses: Int = 0,
        totalRestarts: Int = 0,
        totalUptime: TimeInterval = 0
    ) {
        self.timestamp = timestamp
        self.processes = processes
        self.totalProcesses = totalProcesses
        self.runningProcesses = runningProcesses
        self.erroredProcesses = erroredProcesses
        self.stoppedProcesses = stoppedProcesses
        self.totalRestarts = totalRestarts
        self.totalUptime = totalUptime
    }

    public struct ProcessInfo: Sendable, Codable, Identifiable {
        public let id: String
        public let name: String
        public let pid: Int?
        public let status: String
        public let uptime: TimeInterval
        public let restarts: Int
        public let cpu: Double
        public let memory: Double
        public let watching: Bool

        public init(
            id: String,
            name: String,
            pid: Int? = nil,
            status: String,
            uptime: TimeInterval = 0,
            restarts: Int = 0,
            cpu: Double = 0,
            memory: Double = 0,
            watching: Bool = false
        ) {
            self.id = id
            self.name = name
            self.pid = pid
            self.status = status
            self.uptime = uptime
            self.restarts = restarts
            self.cpu = cpu
            self.memory = memory
            self.watching = watching
        }
    }
}

/// 📊 Time-series data point
@available(macOS 14, iOS 17, *)
public struct MetricPoint: Sendable, Codable {
    public let timestamp: Date
    public let value: Double
    public let label: String?
    public let tags: [String: String]

    public init(
        timestamp: Date = Date(),
        value: Double,
        label: String? = nil,
        tags: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.value = value
        self.label = label
        self.tags = tags
    }
}

/// 📈 Metrics collection with time-based indexing
@available(macOS 14, iOS 17, *)
public struct MetricsCollection: Sendable {
    private let points: [MetricPoint]

    public init(points: [MetricPoint] = []) {
        self.points = points.sorted { $0.timestamp < $1.timestamp }
    }

    public func points(in timeRange: ClosedRange<Date>) -> [MetricPoint] {
        points.filter { timeRange.contains($0.timestamp) }
    }

    public func average() -> Double {
        guard !points.isEmpty else { return 0 }
        return points.reduce(0) { $0 + $1.value } / Double(points.count)
    }

    public func max() -> Double? {
        points.map { $0.value }.max()
    }

    public func min() -> Double? {
        points.map { $0.value }.min()
    }

    public func percentile(_ p: Double) -> Double {
        guard !points.isEmpty else { return 0 }
        let sortedValues = points.map { $0.value }.sorted()
        let index = Int(Double(sortedValues.count - 1) * p / 100.0)
        return sortedValues[index]
    }
}
