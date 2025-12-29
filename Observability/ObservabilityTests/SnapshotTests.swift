//
//  SnapshotTests.swift
//  ObservabilityTests
//
//  📸 The Cosmic Snapshot Test Suite - Where UI Perfection Is Verified ✨
//
//  "Every pixel, every variant, every moment captured and verified -
//   because great UIs deserve great tests"
//
//  - The Mystical Snapshot Guardian
//

import XCTest
import SwiftUI
import SnapshotTesting
import ObservabilityCore
import ObservabilityNetworking
import ObservabilityUI
@testable import Observability

// Note: DashboardView and ServiceDetailView are in the main app target
// They are made public to allow snapshot testing
@available(macOS 14, iOS 17, *)
final class SnapshotTests: XCTestCase {
    
    // MARK: - Dashboard View Snapshots
    
    func testDashboardView_iOS_Light_iPhone15Pro() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
        )
    }
    
    func testDashboardView_iOS_Dark_iPhone15Pro() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro)
        )
    }
    
    func testDashboardView_iOS_Light_iPhoneSE() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .light, device: .iPhoneSE)
        )
    }
    
    func testDashboardView_iOS_Dark_iPhoneSE() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .dark, device: .iPhoneSE)
        )
    }
    
    func testDashboardView_iOS_Light_iPadPro() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .light, device: .iPadPro)
        )
    }
    
    func testDashboardView_iOS_Dark_iPadPro() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .iOS, colorScheme: .dark, device: .iPadPro)
        )
    }
    
    func testDashboardView_macOS_Light() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .macOS, colorScheme: .light, device: .macBookPro)
        )
    }
    
    func testDashboardView_macOS_Dark() {
        assertSnapshot(
            matching: DashboardView(),
            config: .init(platform: .macOS, colorScheme: .dark, device: .macBookPro)
        )
    }
    
    // MARK: - Service Detail View Snapshots
    
    func testServiceDetailView_iOS_Light_iPhone15Pro() {
        let service = ServiceInfo(
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .cms,
            description: "Content Management System backend",
            icon: "folder.fill",
            tags: ["production", "critical", "cms"]
        )
        
        let health = HealthCheckResult(
            serviceId: service.id,
            status: .operational,
            responseTime: 0.05,
            metrics: [
                "cpu": .double(25.5),
                "memory": .double(125.3),
                "restarts": .int(2)
            ]
        )
        
        assertSnapshot(
            matching: NavigationStack {
                ServiceDetailView(service: service, health: health)
            },
            config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)
        )
    }
    
    func testServiceDetailView_iOS_Dark_iPhone15Pro() {
        let service = ServiceInfo(
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .cms,
            description: "Content Management System backend",
            icon: "folder.fill",
            tags: ["production", "critical", "cms"]
        )
        
        let health = HealthCheckResult(
            serviceId: service.id,
            status: .operational,
            responseTime: 0.05,
            metrics: [
                "cpu": .double(25.5),
                "memory": .double(125.3),
                "restarts": .int(2)
            ]
        )
        
        assertSnapshot(
            matching: NavigationStack {
                ServiceDetailView(service: service, health: health)
            },
            config: .init(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro)
        )
    }
    
    func testServiceDetailView_macOS_Light() {
        let service = ServiceInfo(
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .cms,
            description: "Content Management System backend",
            icon: "folder.fill",
            tags: ["production", "critical", "cms"]
        )
        
        let health = HealthCheckResult(
            serviceId: service.id,
            status: .operational,
            responseTime: 0.05,
            metrics: [
                "cpu": .double(25.5),
                "memory": .double(125.3),
                "restarts": .int(2)
            ]
        )
        
        assertSnapshot(
            matching: NavigationStack {
                ServiceDetailView(service: service, health: health)
            },
            config: .init(platform: .macOS, colorScheme: .light, device: .macBookPro)
        )
    }
    
    func testServiceDetailView_macOS_Dark() {
        let service = ServiceInfo(
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .cms,
            description: "Content Management System backend",
            icon: "folder.fill",
            tags: ["production", "critical", "cms"]
        )
        
        let health = HealthCheckResult(
            serviceId: service.id,
            status: .operational,
            responseTime: 0.05,
            metrics: [
                "cpu": .double(25.5),
                "memory": .double(125.3),
                "restarts": .int(2)
            ]
        )
        
        assertSnapshot(
            matching: NavigationStack {
                ServiceDetailView(service: service, health: health)
            },
            config: .init(platform: .macOS, colorScheme: .dark, device: .macBookPro)
        )
    }
}
