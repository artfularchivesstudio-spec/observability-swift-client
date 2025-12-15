//
//  MetricChart_Previews.swift
//  ObservabilityUI
//
//  📊 The Cosmic Chart Gallery - Where Metrics Become Visual Art ✨
//

import SwiftUI
import Combine
import ObservabilityCore

// MARK: - MetricChart Previews

@available(macOS 14, iOS 17, *)
struct MetricChart_Previews: PreviewProvider {
    static let samplePublisher = Timer.publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
        .map { _ in
            MetricPoint(
                value: Double.random(in: 0...100),
                label: "cpu",
                tags: ["service": "sample"]
            )
        }
        .eraseToAnyPublisher()

    static var previews: some View {
        Group {
            // Line Chart
            MetricChart(
                title: "CPU Usage",
                metricsPublisher: samplePublisher,
                maxDataPoints: 40,
                chartType: .line
            )
            .padding()
            .previewDisplayName("Line Chart")

            // Area Chart
            MetricChart(
                title: "Memory Usage",
                metricsPublisher: samplePublisher,
                maxDataPoints: 40,
                chartType: .area
            )
            .padding()
            .previewDisplayName("Area Chart")

            // Light/Dark Mode
            MetricChart(
                title: "CPU Usage",
                metricsPublisher: samplePublisher,
                maxDataPoints: 40,
                chartType: .line
            )
            .padding()
            .previewDisplayName("Light Mode")

            MetricChart(
                title: "CPU Usage",
                metricsPublisher: samplePublisher,
                maxDataPoints: 40,
                chartType: .line
            )
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")

            // Platform Sizes
            MetricChart(
                title: "CPU",
                metricsPublisher: samplePublisher,
                maxDataPoints: 30,
                chartType: .line
            )
            .padding()
            .previewLayout(.fixed(width: 350, height: 180))
            .previewDisplayName("iPhone SE")

            MetricChart(
                title: "System Metrics",
                metricsPublisher: samplePublisher,
                maxDataPoints: 50,
                chartType: .area
            )
            .padding()
            .previewLayout(.fixed(width: 800, height: 250))
            .previewDisplayName("iPad")
        }
    }
}

// MARK: - MetricGauge Previews

@available(macOS 14, iOS 17, *)
struct MetricGauge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Various Values
            HStack(spacing: 20) {
                MetricGauge(
                    title: "CPU",
                    value: 75,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )

                MetricGauge(
                    title: "Memory",
                    value: 45,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )

                MetricGauge(
                    title: "Disk",
                    value: 92,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )
            }
            .padding()
            .previewDisplayName("Multiple Gauges")

            // Light Mode
            MetricGauge(
                title: "CPU Usage",
                value: 67.5,
                minValue: 0,
                maxValue: 100,
                unit: "%"
            )
            .padding()
            .previewDisplayName("Light Mode")

            // Dark Mode
            MetricGauge(
                title: "CPU Usage",
                value: 67.5,
                minValue: 0,
                maxValue: 100,
                unit: "%"
            )
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")

            // Platform Sizes
            MetricGauge(
                title: "CPU",
                value: 45,
                minValue: 0,
                maxValue: 100,
                unit: "%"
            )
            .padding()
            .previewLayout(.fixed(width: 200, height: 200))
            .previewDisplayName("Compact")

            MetricGauge(
                title: "System Health",
                value: 78.3,
                minValue: 0,
                maxValue: 100,
                unit: "%"
            )
            .padding()
            .previewLayout(.fixed(width: 400, height: 400))
            .previewDisplayName("Large")
        }
    }
}

// MARK: - MetricsDashboard Previews

@available(macOS 14, iOS 17, *)
struct MetricsDashboard_Previews: PreviewProvider {
    static let samplePublisher = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .map { _ in
            MetricPoint(
                value: Double.random(in: 0...100),
                label: ["cpu", "memory", "disk"].randomElement()!,
                tags: ["service": "sample"]
            )
        }
        .eraseToAnyPublisher()

    static var previews: some View {
        Group {
            // Full Dashboard
            MetricsDashboard(
                title: "System Overview",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {
                print("Refreshing dashboard...")
            }
            .previewDisplayName("Full Dashboard")

            // Light Mode
            MetricsDashboard(
                title: "System Overview",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {}
            .previewDisplayName("Light Mode")

            // Dark Mode
            MetricsDashboard(
                title: "System Overview",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {}
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")

            // Platform Sizes
            MetricsDashboard(
                title: "Overview",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {}
            .previewLayout(.fixed(width: 375, height: 400))
            .previewDisplayName("iPhone SE")

            MetricsDashboard(
                title: "System Overview",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {}
            .previewLayout(.fixed(width: 834, height: 600))
            .previewDisplayName("iPad")

            MetricsDashboard(
                title: "Infrastructure Metrics",
                metricsPublisher: samplePublisher,
                refreshInterval: 2.0
            ) {}
            .previewLayout(.fixed(width: 1200, height: 800))
            .previewDisplayName("macOS")
        }
    }
}

// MARK: - Combined Dashboard Preview

@available(macOS 14, iOS 17, *)
struct ServiceDashboard_Previews: PreviewProvider {
    static var previews: some View {
        ServiceDashboardPreview()
    }
}

@available(macOS 14, iOS 17, *)
struct ServiceDashboardPreview: View {
    let sampleMetrics = PreviewData.createSampleMetricPublisher()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Infrastructure Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Real-time service monitoring")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Status Filters
                HStack(spacing: 12) {
                    StatusFilterButton(label: "All", count: 5, isSelected: true) {}
                    StatusFilterButton(label: "Operational", count: 3, isSelected: false) {}
                    StatusFilterButton(label: "Warning", count: 1, isSelected: false) {}
                    StatusFilterButton(label: "Critical", count: 1, isSelected: false) {}

                    Spacer()
                }

                // Service Grid
                ServiceGrid(
                    services: PreviewData.sampleServices,
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { service in
                        print("Tapped on \(service.name)")
                    }
                )

                // Metrics Dashboard
                MetricsDashboard(
                    title: "System Metrics",
                    metricsPublisher: sampleMetrics,
                    refreshInterval: 3.0
                ) {}
            }
            .padding()
        }
        .previewDisplayName("Combined Dashboard - Light")

        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Infrastructure Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Real-time service monitoring")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Status Filters
                HStack(spacing: 12) {
                    StatusFilterButton(label: "All", count: 5, isSelected: true) {}
                    StatusFilterButton(label: "Operational", count: 3, isSelected: false) {}
                    StatusFilterButton(label: "Warning", count: 1, isSelected: false) {}
                    StatusFilterButton(label: "Critical", count: 1, isSelected: false) {}

                    Spacer()
                }

                // Service Grid
                ServiceGrid(
                    services: PreviewData.sampleServices,
                    healthResults: PreviewData.sampleHealthResults,
                    onServiceTap: { service in
                        print("Tapped on \(service.name)")
                    }
                )

                // Metrics Dashboard
                MetricsDashboard(
                    title: "System Metrics",
                    metricsPublisher: sampleMetrics,
                    refreshInterval: 3.0
                ) {}
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .previewDisplayName("Combined Dashboard - Dark")
    }
}
