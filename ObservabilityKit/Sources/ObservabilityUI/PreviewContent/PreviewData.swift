//
//  PreviewData.swift
//  ObservabilityUI
//
//  🎭 The Cosmic Preview Factory - Where UI Components Dance in Xcode's Spotlight ✨
//

import Foundation
import ObservabilityCore

@available(macOS 14, iOS 17, *)
public enum PreviewData {
    public static let sampleServices: [ServiceInfo] = [
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "http://localhost:1337"),
            category: .cms,
            description: "Main content management system",
            icon: "folder.fill",
            tags: ["production", "critical"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            name: "Next.js Frontend",
            type: .nextjs,
            port: 3000,
            baseURL: URL(string: "http://localhost:3000"),
            category: .frontend,
            description: "User-facing web application",
            icon: "globe",
            tags: ["production", "user-facing"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
            name: "Python API",
            type: .flask,
            port: 8000,
            baseURL: URL(string: "http://localhost:8000"),
            category: .backend,
            description: "Backend API service",
            icon: "server.rack",
            tags: ["production", "api"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
            name: "PostgreSQL",
            type: .postgresql,
            port: 5432,
            baseURL: nil,
            category: .database,
            description: "Primary database",
            icon: "externaldrive.fill",
            tags: ["production", "data"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
            name: "Redis Cache",
            type: .redis,
            port: 6379,
            baseURL: nil,
            category: .infrastructure,
            description: "In-memory cache layer",
            icon: "memorychip",
            tags: ["cache", "performance"]
        )
    ]

    public static func sampleHealth(for serviceId: UUID) -> HealthCheckResult {
        let statuses: [ServiceStatus] = [
            .operational,
            .degraded(responseTime: 0.15, errorRate: 0.02),
            .down(lastSeen: Date().addingTimeInterval(-300), reason: "Connection timeout")
        ]

        let status = statuses[Int(serviceId.uuid.0) % statuses.count]
        let responseTime = Double.random(in: 0.01...0.5)

        return HealthCheckResult(
            serviceId: serviceId,
            timestamp: Date(),
            status: status,
            responseTime: responseTime,
            metrics: [
                "cpu": .double(Double.random(in: 0...100)),
                "memory": .double(Double.random(in: 0...1000)),
                "requests": .int(Int.random(in: 100...10000))
            ],
            checks: [
                "http_probe": .passed,
                "database": .passed,
                "disk_space": .warning("Disk space getting low")
            ]
        )
    }

    public static var sampleHealthResults: [UUID: HealthCheckResult] {
        Dictionary(
            uniqueKeysWithValues: sampleServices.map { service in
                (service.id, sampleHealth(for: service.id))
            }
        )
    }

    public static let sampleAlerts: [Alert] = [
        Alert(
            id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440000")!,
            title: "High CPU Usage",
            message: "Server CPU usage has exceeded 85% for more than 5 minutes",
            severity: .warning,
            source: Alert.AlertSource(
                serviceId: sampleServices[0].id,
                serviceName: "Strapi CMS",
                checkType: "cpu_monitor",
                location: "us-east-1"
            ),
            timestamp: Date().addingTimeInterval(-300),
            acknowledged: false,
            resolved: false,
            tags: ["performance", "cpu"],
            metadata: ["cpu_value": "87.5", "threshold": "85"]
        ),
        Alert(
            id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440001")!,
            title: "Database Connection Failed",
            message: "Unable to connect to PostgreSQL database",
            severity: .critical,
            source: Alert.AlertSource(
                serviceId: sampleServices[3].id,
                serviceName: "PostgreSQL",
                checkType: "connection_test",
                location: "us-east-1"
            ),
            timestamp: Date().addingTimeInterval(-60),
            acknowledged: false,
            resolved: false,
            tags: ["database", "connectivity"],
            metadata: ["error": "connection timeout", "attempts": "3"]
        ),
        Alert(
            id: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440002")!,
            title: "Service Maintenance",
            message: "Next.js frontend is undergoing scheduled maintenance",
            severity: .info,
            source: Alert.AlertSource(
                serviceId: sampleServices[1].id,
                serviceName: "Next.js Frontend",
                checkType: "maintenance_mode",
                location: "us-east-1"
            ),
            timestamp: Date().addingTimeInterval(-900),
            acknowledged: true,
            resolved: false,
            tags: ["maintenance", "scheduled"],
            metadata: ["duration": "30 minutes", "start_time": "02:00 UTC"]
        )
    ]

    // Publisher for real-time preview simulation
    public static func createSampleMetricPublisher() -> AnyPublisher<MetricPoint, Never> {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in
                MetricPoint(
                    value: Double.random(in: 0...100),
                    label: ["cpu", "memory", "disk", "network"].randomElement(),
                    tags: ["service": "sample"]
                )
            }
            .eraseToAnyPublisher()
    }

    public static var sampleSystemMetrics: SystemMetrics {
        SystemMetrics(
            timestamp: Date(),
            cpuUsage: Double.random(in: 0...100),
            memoryUsage: Double.random(in: 500...16000),
            memoryTotal: 16000,
            diskUsage: Double.random(in: 100...500),
            diskTotal: 500,
            loadAverage: [1.5, 1.8, 2.0],
            networkStats: SystemMetrics.NetworkStats(
                bytesIn: Double.random(in: 1000...100000),
                bytesOut: Double.random(in: 1000...100000),
                packetsIn: Int.random(in: 100...10000),
                packetsOut: Int.random(in: 100...10000),
                errorsIn: Int.random(in: 0...10),
                errorsOut: Int.random(in: 0...10)
            )
        )
    }
}
