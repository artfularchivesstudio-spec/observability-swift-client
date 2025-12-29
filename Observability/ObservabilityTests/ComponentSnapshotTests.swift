//
//  ComponentSnapshotTests.swift
//  ObservabilityTests
//
//  📸 Component-Level Snapshot Tests - Where UI Components Are Verified ✨
//
//  "Testing individual components ensures the building blocks are perfect,
//   before we assemble them into complete views"
//
//  - The Mystical Component Tester
//

import XCTest
import SwiftUI
import SnapshotTesting
import Combine
import ObservabilityCore
import ObservabilityUI

@available(macOS 14, iOS 17, *)
final class ComponentSnapshotTests: XCTestCase {
    
    // MARK: - Service Status Indicator Tests
    
    func testServiceStatusIndicator_Operational_iOS_Light() {
        assertSnapshot(
            matching: ServiceStatusIndicator(status: .operational),
            config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
        )
    }
    
    func testServiceStatusIndicator_Degraded_iOS_Dark() {
        assertSnapshot(
            matching: ServiceStatusIndicator(status: .degraded(responseTime: 1.5, errorRate: 0.1)),
            config: .init(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro)
        )
    }
    
    func testServiceStatusIndicator_Down_macOS_Light() {
        assertSnapshot(
            matching: ServiceStatusIndicator(status: .down(lastSeen: Date(), reason: "Connection timeout")),
            config: .init(platform: .macOS, colorScheme: .light, device: .macBookPro)
        )
    }
    
    func testServiceStatusIndicator_Down_macOS_Dark() {
        assertSnapshot(
            matching: ServiceStatusIndicator(status: .down(lastSeen: Date(), reason: "Connection timeout")),
            config: .init(platform: .macOS, colorScheme: .dark, device: .macBookPro)
        )
    }
    
    // MARK: - Metric Chart Tests
    // Note: MetricChart uses a publisher-based API, so we'll test it with a simple publisher
    
    func testMetricChart_iOS_Light() {
        let metrics: [MetricPoint] = [
            MetricPoint(timestamp: Date().addingTimeInterval(-300), value: 25.5, label: "cpu"),
            MetricPoint(timestamp: Date().addingTimeInterval(-240), value: 30.2, label: "cpu"),
            MetricPoint(timestamp: Date().addingTimeInterval(-180), value: 28.1, label: "cpu"),
            MetricPoint(timestamp: Date().addingTimeInterval(-120), value: 32.5, label: "cpu"),
            MetricPoint(timestamp: Date().addingTimeInterval(-60), value: 27.8, label: "cpu"),
            MetricPoint(timestamp: Date(), value: 29.3, label: "cpu")
        ]
        
        let publisher = metrics.publisher.eraseToAnyPublisher()
        
        assertSnapshot(
            matching: MetricChart(title: "CPU Usage", metricsPublisher: publisher),
            config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
        )
    }
}
