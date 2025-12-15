//
//  ServiceStatusTests.swift
//  ObservabilityCoreTests
//
//  🧪 The Cosmic Status Validator - Where Service States Face Rigorous Verification ✨
//

import XCTest
import ObservabilityCore

@available(macOS 14, iOS 17, *)
final class ServiceStatusTests: XCTestCase {

    // MARK: - Service Status Tests

    func testServiceStatusOperational() {
        let status = ServiceStatus.operational

        XCTAssertTrue(status.isOperational)
        XCTAssertEqual(status.severity, .info)
        XCTAssertTrue(status.description.contains("operational"))
    }

    func testServiceStatusDegraded() {
        let responseTime = 0.15
        let errorRate = 0.02
        let status = ServiceStatus.degraded(responseTime: responseTime, errorRate: errorRate)

        XCTAssertFalse(status.isOperational)
        XCTAssertEqual(status.severity, .warning)
        XCTAssertTrue(status.description.contains("150ms"))
        XCTAssertTrue(status.description.contains("2%"))
    }

    func testServiceStatusDown() {
        let lastSeen = Date().addingTimeInterval(-300)
        let reason = "Connection timeout"
        let status = ServiceStatus.down(lastSeen: lastSeen, reason: reason)

        XCTAssertFalse(status.isOperational)
        XCTAssertEqual(status.severity, .critical)
        XCTAssertTrue(status.description.contains("timeout"))
        XCTAssertTrue(status.description.contains("5 minutes"))
    }

    func testServiceStatusMaintenance() {
        let scheduledUntil = Date().addingTimeInterval(3600)
        let status = ServiceStatus.maintenance(scheduledUntil: scheduledUntil)

        XCTAssertFalse(status.isOperational)
        XCTAssertEqual(status.severity, .info)
        XCTAssertTrue(status.description.contains("maintenance"))
    }

    func testServiceStatusUnknown() {
        let status: ServiceStatus = .unknown

        XCTAssertFalse(status.isOperational)
        XCTAssertEqual(status.severity, .error)
        XCTAssertTrue(status.description.contains("unknown"))
    }

    // MARK: - Service Info Tests

    func testServiceInfoInitialization() {
        let service = ServiceInfo(
            id: UUID(),
            name: "Test Service",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "http://localhost:1337"),
            category: .cms,
            description: "A test service",
            icon: "folder.fill",
            tags: ["test", "cms"]
        )

        XCTAssertEqual(service.name, "Test Service")
        XCTAssertEqual(service.type, .strapi)
        XCTAssertEqual(service.port, 1337)
        XCTAssertEqual(service.category, .cms)
        XCTAssertNotNil(service.baseURL)
        XCTAssertEqual(service.tags.count, 2)
    }

    func testServiceInfoTypeDisplayNames() {
        XCTAssertEqual(ServiceInfo.ServiceType.strapi.displayName, "Strapi")
        XCTAssertEqual(ServiceInfo.ServiceType.nextjs.displayName, "Next.js")
        XCTAssertEqual(ServiceInfo.ServiceType.postgresql.displayName, "PostgreSQL")
    }

    func testServiceInfoCategoryColors() {
        XCTAssertEqual(ServiceInfo.ServiceCategory.cms.color, "#3498db")
        XCTAssertEqual(ServiceInfo.ServiceCategory.frontend.color, "#e74c3c")
        XCTAssertEqual(ServiceInfo.ServiceCategory.backend.color, "#2ecc71")
    }

    func testServiceInfoIdentifiable() {
        let service1 = ServiceInfo(
            name: "Service 1",
            type: .strapi,
            category: .cms
        )
        let service2 = ServiceInfo(
            name: "Service 2",
            type: .nextjs,
            category: .frontend
        )

        XCTAssertNotEqual(service1.id, service2.id)
    }

    // MARK: - Health Check Result Tests

    func testHealthCheckResultInitialization() {
        let serviceId = UUID()
        let status = ServiceStatus.operational
        let health = HealthCheckResult(
            serviceId: serviceId,
            status: status,
            responseTime: 0.05,
            metrics: ["cpu": .double(45.5)],
            checks: ["http": .passed]
        )

        XCTAssertEqual(health.serviceId, serviceId)
        XCTAssertEqual(health.status, status)
        XCTAssertEqual(health.responseTime, 0.05)
        XCTAssertNotNil(health.metrics["cpu"])
        XCTAssertEqual(health.checks["http"], .passed)
    }

    func testHealthCheckResultMetrics() {
        let health = HealthCheckResult(
            serviceId: UUID(),
            status: .operational,
            responseTime: 0.1,
            metrics: [
                "cpu": .double(50.0),
                "memory": .int(4096),
                "requests": .string("1000")
            ]
        )

        XCTAssertEqual(health.metrics["cpu"]?.doubleValue, 50.0)
        XCTAssertEqual(health.metrics["memory"]?.intValue, 4096)
        XCTAssertNotNil(health.metrics["requests"])
    }

    func testCheckResultSuccessState() {
        let passed: HealthCheckResult.CheckResult = .passed
        let failed: HealthCheckResult.CheckResult = .failed(
            HealthCheckResult.ErrorInfo(code: "TIMEOUT", message: "Timeout")
        )
        let warning: HealthCheckResult.CheckResult = .warning("High memory usage")

        XCTAssertTrue(passed.isSuccess)
        XCTAssertFalse(failed.isSuccess)
        XCTAssertFalse(warning.isSuccess)
    }
}

// MARK: - ServiceStatus Helper Cases

@available(macOS 14, iOS 17, *)
extension ServiceStatus {
    var displayName: String {
        switch self {
        case .operational:
            return "Operational"
        case .degraded(responseTime: _, errorRate: _):
            return "Degraded"
        case .down(lastSeen: _, reason: _):
            return "Down"
        case .maintenance(scheduledUntil: _):
            return "Maintenance"
        case .unknown:
            return "Unknown"
        }
    }

    static var allCases: [ServiceStatus] {
        [
            .operational,
            .degraded(responseTime: 0.1, errorRate: 0.01),
            .down(lastSeen: Date(), reason: "Unknown"),
            .maintenance(scheduledUntil: Date().addingTimeInterval(3600)),
            .unknown
        ]
    }
}
