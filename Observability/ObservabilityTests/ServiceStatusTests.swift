//
//  ServiceStatusTests.swift
//  ObservabilityTests
//
//  🧪 Service Status Tests - Where Service States Are Verified ✨
//

#if canImport(Testing)
import Testing
#else
import XCTest
#endif
import Foundation
import ObservabilityCore

@available(macOS 14, iOS 17, *)
@Suite("ServiceStatus Tests")
struct ServiceStatusTests {
    
    @Test("Operational status is operational")
    func testOperationalStatus() {
        let status = ServiceStatus.operational
        #expect(status.isOperational == true)
        #expect(status.severity == .info)
    }
    
    @Test("Degraded status is not operational")
    func testDegradedStatus() {
        let status = ServiceStatus.degraded(responseTime: 0.2, errorRate: 0.05)
        #expect(status.isOperational == false)
        #expect(status.severity == .warning)
    }
    
    @Test("Down status is critical")
    func testDownStatus() {
        let status = ServiceStatus.down(
            lastSeen: Date(),
            reason: "Connection failed"
        )
        #expect(status.isOperational == false)
        #expect(status.severity == .critical)
    }
    
    @Test("ServiceStatus display names")
    func testDisplayNames() {
        #expect(ServiceStatus.operational.displayName == "Operational")
        #expect(ServiceStatus.unknown.displayName == "Unknown")
    }
}

