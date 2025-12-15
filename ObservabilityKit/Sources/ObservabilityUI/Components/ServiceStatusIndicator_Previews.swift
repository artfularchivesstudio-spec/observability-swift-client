//
//  ServiceStatusIndicator_Previews.swift
//  ObservabilityUI
//
//  🎭 The Cosmic Preview Gallery - Where UI Components Shine in Xcode's Spotlight ✨
//

import SwiftUI
import ObservabilityCore

// MARK: - ServiceStatusIndicator Previews

@available(macOS 14, iOS 17, *)
struct ServiceStatusIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // All Status Types
            VStack(spacing: 20) {
                ServiceStatusIndicator(status: .operational, showLabel: true)
                ServiceStatusIndicator(status: .degraded(responseTime: 0.15, errorRate: 0.02), showLabel: true)
                ServiceStatusIndicator(status: .down(lastSeen: Date().addingTimeInterval(-300), reason: "Connection timeout"), showLabel: true)
                ServiceStatusIndicator(status: .maintenance(scheduledUntil: Date().addingTimeInterval(3600)), showLabel: true)
                ServiceStatusIndicator(status: .unknown, showLabel: true)
            }
            .padding()
            .previewDisplayName("All Status Types")

            // Light and Dark Modes
            Group {
                VStack(spacing: 20) {
                    ServiceStatusIndicator(status: .operational, showLabel: true)
                    ServiceStatusIndicator(status: .degraded(responseTime: 0.15, errorRate: 0.02), showLabel: false)
                    ServiceStatusIndicator(status: .operational, showLabel: false)
                }
                .padding()
                .previewDisplayName("Light Mode")

                VStack(spacing: 20) {
                    ServiceStatusIndicator(status: .operational, showLabel: true)
                    ServiceStatusIndicator(status: .degraded(responseTime: 0.15, errorRate: 0.02), showLabel: false)
                    ServiceStatusIndicator(status: .operational, showLabel: false)
                }
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            }

            // Platform Sizes
            HStack(spacing: 12) {
                ServiceStatusIndicator(status: .operational, showLabel: true)
                ServiceStatusIndicator(status: .degraded(responseTime: 0.15, errorRate: 0.02), showLabel: true)
            }
            .padding()
            .previewLayout(.fixed(width: 300, height: 100))
            .previewDisplayName("Compact Width - iPhone SE")

            HStack(spacing: 12) {
                ServiceStatusIndicator(status: .operational, showLabel: true)
                ServiceStatusIndicator(status: .degraded(responseTime: 0.15, errorRate: 0.02), showLabel: true)
            }
            .padding()
            .previewLayout(.fixed(width: 600, height: 100))
            .previewDisplayName("Wide Width - iPad")
        }
    }
}

// MARK: - ServiceCard Previews

@available(macOS 14, iOS 17, *)
struct ServiceCard_Previews: PreviewProvider {
    static let sampleService = PreviewData.sampleServices[0]
    static let sampleHealth = PreviewData.sampleHealth(for: sampleService.id)

    static var previews: some View {
        Group {
            // Individual Service Cards
            VStack(spacing: 16) {
                ServiceCard(service: sampleService, health: sampleHealth)
                ServiceCard(service: sampleService, health: nil) // Loading state
            }
            .padding()
            .previewDisplayName("Service Cards")

            // Light/Dark Mode
            ServiceCard(service: sampleService, health: sampleHealth)
                .padding()
                .previewDisplayName("Light Mode")

            ServiceCard(service: sampleService, health: sampleHealth)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")

            // Different Sizes
            ServiceCard(service: sampleService, health: sampleHealth)
                .padding()
                .previewLayout(.fixed(width: 400, height: 120))
                .previewDisplayName("Width: 400")

            ServiceCard(service: sampleService, health: sampleHealth)
                .padding()
                .previewLayout(.fixed(width: 300, height: 120))
                .previewDisplayName("Width: 300")
        }
    }
}

// MARK: - ServiceGrid Previews

@available(macOS 14, iOS 17, *)
struct ServiceGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full Grid
            ScrollView {
                ServiceGrid(
                    services: PreviewData.sampleServices,
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .previewDisplayName("All Services")

            // Light Mode
            ScrollView {
                ServiceGrid(
                    services: Array(PreviewData.sampleServices.prefix(3)),
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .previewDisplayName("Grid - Light")

            // Dark Mode
            ScrollView {
                ServiceGrid(
                    services: Array(PreviewData.sampleServices.prefix(3)),
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Grid - Dark")

            // Platform Sizes
            ScrollView {
                ServiceGrid(
                    services: Array(PreviewData.sampleServices.prefix(2)),
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .previewLayout(.fixed(width: 375, height: 300)) // iPhone SE
            .previewDisplayName("iPhone SE")

            ScrollView {
                ServiceGrid(
                    services: Array(PreviewData.sampleServices.prefix(2)),
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .previewLayout(.fixed(width: 834, height: 400)) // iPad
            .previewDisplayName("iPad")

            ScrollView {
                ServiceGrid(
                    services: Array(PreviewData.sampleServices.prefix(4)),
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { _ in }
                )
            }
            .padding()
            .previewLayout(.fixed(width: 1024, height: 600)) // macOS
            .previewDisplayName("macOS")
        }
    }
}

// MARK: - StatusFilterButton Previews

@available(macOS 14, iOS 17, *)
struct StatusFilterButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Individual Buttons
            HStack(spacing: 12) {
                StatusFilterButton(label: "All", count: 42, isSelected: true) {}
                StatusFilterButton(label: "Warning", count: 3, isSelected: false) {}
                StatusFilterButton(label: "Critical", count: 1, isSelected: false) {}
            }
            .padding()
            .previewDisplayName("Filter Buttons")

            // Light/Dark Modes
            HStack(spacing: 12) {
                StatusFilterButton(label: "All", count: 42, isSelected: true) {}
                StatusFilterButton(label: "Warning", count: 3, isSelected: false) {}
            }
            .padding()
            .previewDisplayName("Light Mode")

            HStack(spacing: 12) {
                StatusFilterButton(label: "All", count: 42, isSelected: true) {}
                StatusFilterButton(label: "Warning", count: 3, isSelected: false) {}
            }
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")

            // Different States
            VStack(spacing: 8) {
                StatusFilterButton(label: "All Services", count: 156, isSelected: true) {}
                StatusFilterButton(label: "Warning", count: 3, isSelected: false) {}
                StatusFilterButton(label: "Critical", count: 1, isSelected: false) {}
                StatusFilterButton(label: "Maintenance", count: 2, isSelected: false) {}
            }
            .padding()
            .previewDisplayName("Multiple States")
        }
    }
}
