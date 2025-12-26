//
//  DashboardViewModelTests.swift
//  ObservabilityTests
//
//  🧪 The Cosmic Test Suite - Where Code Meets Its Destiny ✨
//
//  "The rigorous examination of our observability orchestra,
//   ensuring every note plays in perfect harmony"
//
//  - The Mystical Test Conductor
//

#if canImport(Testing)
import Testing
#else
import XCTest
#endif
import Foundation
import ObservabilityCore
import ObservabilityNetworking

@available(macOS 14, iOS 17, *)
@Suite("DashboardViewModel Tests")
struct DashboardViewModelTests {
    
    // Note: DashboardViewModel is in the app target, so we test through public APIs
    // For full testing, consider moving ViewModel to ObservabilityKit or using integration tests
    
    @Test("ServiceInfo model validation")
    func testServiceInfoModel() {
        let service = ServiceInfo(
            name: "Test Service",
            type: .strapi,
            category: .cms,
            description: "Test description"
        )
        
        #expect(service.name == "Test Service")
        #expect(service.type == .strapi)
        #expect(service.category == .cms)
    }
    
    @Test("HealthCheckResult status checks")
    func testHealthCheckResultStatus() {
        let operational = HealthCheckResult(
            serviceId: UUID(),
            status: .operational,
            responseTime: 0.05,
            metrics: [:]
        )
        #expect(operational.status.isOperational == true)
        
        let degraded = HealthCheckResult(
            serviceId: UUID(),
            status: .degraded(responseTime: 0.2, errorRate: 0.05),
            responseTime: 0.2,
            metrics: [:]
        )
        #expect(degraded.status.isOperational == false)
    }
    
    @Test("Alert resolution filtering")
    func testAlertResolution() {
        let unresolvedAlert = Alert(
            title: "Test",
            message: "Test",
            severity: .error,
            source: Alert.AlertSource(serviceName: "Test", checkType: "test"),
            resolved: false
        )
        
        let resolvedAlert = Alert(
            title: "Test",
            message: "Test",
            severity: .error,
            source: Alert.AlertSource(serviceName: "Test", checkType: "test"),
            resolved: true
        )
        
        let alerts = [unresolvedAlert, resolvedAlert]
        let activeCount = alerts.filter { !$0.resolved }.count
        
        #expect(activeCount == 1)
    }
}

