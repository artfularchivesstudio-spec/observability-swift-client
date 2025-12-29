//
//  PreviewVariants.swift
//  ObservabilityTests
//
//  🎨 The Cosmic Preview Variants - Where Every UI Combination Lives ✨
//
//  "Previews for every platform, every color scheme, every device size -
//   because great UIs deserve to be seen in every light"
//
//  - The Mystical Preview Virtuoso
//

import SwiftUI
import ObservabilityCore
import ObservabilityNetworking
import ObservabilityUI

// Import app views (these are in the main app target)
// Note: In a real scenario, these would be @testable imports or public APIs

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// 🎭 Preview wrapper for all variants
@available(macOS 14, iOS 17, *)
public struct PreviewVariants<Content: View>: View {
    let content: Content
    let config: SnapshotConfig
    
    public init(config: SnapshotConfig, @ViewBuilder content: () -> Content) {
        self.config = config
        self.content = content()
    }
    
    public var body: some View {
        content
            .preferredColorScheme(config.colorScheme)
            .frame(width: config.device.size.width, height: config.device.size.height)
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
    }
}

// MARK: - Dashboard View Variants

@available(macOS 14, iOS 17, *)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iOS Light - iPhone 15 Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)) {
                DashboardView()
            }
            .previewDisplayName("iOS Light - iPhone 15 Pro")
            
            // iOS Dark - iPhone 15 Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro)) {
                DashboardView()
            }
            .previewDisplayName("iOS Dark - iPhone 15 Pro")
            
            // iOS Light - iPhone SE
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .light, device: .iPhoneSE)) {
                DashboardView()
            }
            .previewDisplayName("iOS Light - iPhone SE")
            
            // iOS Dark - iPhone SE
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .dark, device: .iPhoneSE)) {
                DashboardView()
            }
            .previewDisplayName("iOS Dark - iPhone SE")
            
            // iOS Light - iPad Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .light, device: .iPadPro)) {
                DashboardView()
            }
            .previewDisplayName("iOS Light - iPad Pro")
            
            // iOS Dark - iPad Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .dark, device: .iPadPro)) {
                DashboardView()
            }
            .previewDisplayName("iOS Dark - iPad Pro")
            
            // macOS Light
            PreviewVariants(config: .init(platform: .macOS, colorScheme: .light, device: .macBookPro)) {
                DashboardView()
            }
            .previewDisplayName("macOS Light")
            
            // macOS Dark
            PreviewVariants(config: .init(platform: .macOS, colorScheme: .dark, device: .macBookPro)) {
                DashboardView()
            }
            .previewDisplayName("macOS Dark")
        }
    }
}

// MARK: - Service Detail View Variants

@available(macOS 14, iOS 17, *)
struct ServiceDetailView_Previews: PreviewProvider {
    static let sampleService = ServiceInfo(
        name: "Strapi CMS",
        type: .strapi,
        port: 1337,
        baseURL: URL(string: "https://api-router.cloud"),
        category: .cms,
        description: "Content Management System backend",
        icon: "folder.fill",
        tags: ["production", "critical", "cms"]
    )
    
    static let sampleHealth = HealthCheckResult(
        serviceId: sampleService.id,
        status: .operational,
        responseTime: 0.05,
        metrics: [
            "cpu": .double(25.5),
            "memory": .double(125.3),
            "restarts": .int(2)
        ]
    )
    
    static var previews: some View {
        Group {
            // iOS Light - iPhone 15 Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .light, device: .iPhone15Pro)) {
                NavigationStack {
                    ServiceDetailView(service: sampleService, health: sampleHealth)
                }
            }
            .previewDisplayName("Service Detail - iOS Light - iPhone 15 Pro")
            
            // iOS Dark - iPhone 15 Pro
            PreviewVariants(config: .init(platform: .iOS, colorScheme: .dark, device: .iPhone15Pro)) {
                NavigationStack {
                    ServiceDetailView(service: sampleService, health: sampleHealth)
                }
            }
            .previewDisplayName("Service Detail - iOS Dark - iPhone 15 Pro")
            
            // macOS Light
            PreviewVariants(config: .init(platform: .macOS, colorScheme: .light, device: .macBookPro)) {
                NavigationStack {
                    ServiceDetailView(service: sampleService, health: sampleHealth)
                }
            }
            .previewDisplayName("Service Detail - macOS Light")
            
            // macOS Dark
            PreviewVariants(config: .init(platform: .macOS, colorScheme: .dark, device: .macBookPro)) {
                NavigationStack {
                    ServiceDetailView(service: sampleService, health: sampleHealth)
                }
            }
            .previewDisplayName("Service Detail - macOS Dark")
        }
    }
}
