//
//  DashboardView.swift
//  Observability
//
//  🎯 The Cosmic Dashboard - Where Infrastructure Becomes Observable Art ✨
//

import SwiftUI
import Combine
import ObservabilityCore
import ObservabilityNetworking
import ObservabilityUI

@available(macOS 14, iOS 17, *)
struct DashboardView: View {
    // MARK: - State
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedService: ServiceInfo?
    @State private var showingAlertDetail = false

    // MARK: - Filter State
    @State private var selectedFilter: ServiceStatus?
    @State private var searchText = ""

    var body: some View {
        #if os(macOS)
        NavigationStack {
            mainContent
        }
        #else
        NavigationStack {
            mainContent
        }
        #endif
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection

                // Status Overview
                statusOverviewSection

                // Services Grid
                servicesSection

                // Real-time Metrics
                if !viewModel.metrics.isEmpty {
                    metricsSection
                }

                // Recent Alerts
                if !viewModel.recentAlerts.isEmpty {
                    alertsSection
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            #if os(macOS)
            .frame(maxWidth: 1400) // Prevent content from being too wide on large screens
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Dashboard")
        .sheet(item: $selectedService) { service in
            NavigationStack {
                ServiceDetailView(
                    service: service,
                    health: viewModel.healthResults[service.id]
                )
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                connectionIndicator
            }
            #else
            ToolbarItem(placement: .automatic) {
                connectionIndicator
            }
            #endif
        }
        .onAppear {
            viewModel.startMonitoring()
            // Request notification permissions
            Task {
                try? await PushNotificationsManager.shared.requestAuthorization()
            }
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            #if os(iOS)
            Text("🎭 Observatory")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            #else
            Text("🎭 Infrastructure Observatory")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            #endif

            Text("Real-time monitoring of your digital ecosystem")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            #if os(macOS)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                StatCard(
                    title: "Services",
                    value: "\(viewModel.services.count)",
                    icon: "server.rack",
                    color: .blue
                )

                StatCard(
                    title: "Healthy",
                    value: "\(viewModel.healthyCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Issues",
                    value: "\(viewModel.issueCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )

                StatCard(
                    title: "Alerts",
                    value: "\(viewModel.activeAlertsCount)",
                    icon: "bell.badge.fill",
                    color: .red
                )
            }
            #else
            HStack(spacing: 20) {
                StatCard(
                    title: "Services",
                    value: "\(viewModel.services.count)",
                    icon: "server.rack",
                    color: .blue
                )

                StatCard(
                    title: "Healthy",
                    value: "\(viewModel.healthyCount)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )

                StatCard(
                    title: "Issues",
                    value: "\(viewModel.issueCount)",
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )

                StatCard(
                    title: "Alerts",
                    value: "\(viewModel.activeAlertsCount)",
                    icon: "bell.badge.fill",
                    color: .red
                )
            }
            #endif
        }
    }

    // MARK: - Status Overview
    private var statusOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Overview")
                .font(.title2)
                .fontWeight(.semibold)

            // Filter Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatusFilterButton(
                        label: "All",
                        count: viewModel.services.count,
                        isSelected: selectedFilter == nil
                    ) {
                        selectedFilter = nil
                    }

                    // Filter by status types (operational, degraded, down)
                    let statusFilters: [(ServiceStatus, String)] = [
                        (.operational, "Operational"),
                        (.degraded(responseTime: 0, errorRate: 0), "Degraded"),
                        (.down(lastSeen: Date(), reason: ""), "Down")
                    ]
                    
                    ForEach(Array(statusFilters.enumerated()), id: \.offset) { _, filter in
                        let (statusType, label) = filter
                        let count = viewModel.services.filter { service in
                            guard let health = viewModel.healthResults[service.id] else { return false }
                            switch (health.status, statusType) {
                            case (.operational, .operational):
                                return true
                            case (.degraded, .degraded):
                                return true
                            case (.down, .down):
                                return true
                            default:
                                return false
                            }
                        }.count

                        StatusFilterButton(
                            label: label,
                            count: count,
                            isSelected: {
                                guard let selected = selectedFilter else { return false }
                                switch (selected, statusType) {
                                case (.operational, .operational): return true
                                case (.degraded, .degraded): return true
                                case (.down, .down): return true
                                default: return false
                                }
                            }()
                        ) {
                            // Create a proper status instance for comparison
                            switch statusType {
                            case .operational:
                                selectedFilter = .operational
                            case .degraded:
                                selectedFilter = .degraded(responseTime: 0, errorRate: 0)
                            case .down:
                                selectedFilter = .down(lastSeen: Date(), reason: "")
                            default:
                                break
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Services Section
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.title2)
                .fontWeight(.semibold)

            ServiceGrid(
                services: filteredServices,
                healthResults: viewModel.healthResults,
                onServiceTap: { service in
                    selectedService = service
                }
            )
        }
    }

    // MARK: - Metrics Section
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Metrics")
                .font(.title2)
                .fontWeight(.semibold)

            #if os(macOS)
            HStack(spacing: 16) {
                MetricGauge(
                    title: "CPU",
                    value: averageCPU,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )
                .frame(maxWidth: .infinity)

                MetricGauge(
                    title: "Memory",
                    value: averageMemory,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )
                .frame(maxWidth: .infinity)
            }
            #else
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                MetricGauge(
                    title: "CPU",
                    value: averageCPU,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )

                MetricGauge(
                    title: "Memory",
                    value: averageMemory,
                    minValue: 0,
                    maxValue: 100,
                    unit: "%"
                )
            }
            #endif

            // Line Chart
            MetricChart(
                title: "CPU Trend",
                metricsPublisher: Just(
                    viewModel.metrics.last ?? MetricPoint(value: 0, label: "cpu")
                ).eraseToAnyPublisher(),
                chartType: .line
            )
        }
    }

    // MARK: - Alerts Section
    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Alerts")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(viewModel.recentAlerts.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.2))
                    )
                    .foregroundColor(.red)
            }

            LazyVStack(spacing: 8) {
                ForEach(viewModel.recentAlerts.prefix(3), id: \.id) { alert in
                    AlertRow(alert: alert)
                        .onTapGesture {
                            #if os(iOS)
                            HapticsManager.shared.playSelection()
                            #endif
                        }
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var filteredServices: [ServiceInfo] {
        viewModel.services.filter { service in
            if let filter = selectedFilter {
                guard let health = viewModel.healthResults[service.id] else { return false }
                return health.status == filter
            }
            return true
        }
    }

    private var averageCPU: Double {
        let cpuMetrics = viewModel.metrics.filter { $0.label == "cpu" }
        guard !cpuMetrics.isEmpty else { return 0 }
        let values = cpuMetrics.map { $0.value }
        return values.reduce(0, +) / Double(values.count)
    }

    private var averageMemory: Double {
        let memoryMetrics = viewModel.metrics.filter { $0.label == "memory" }
        guard !memoryMetrics.isEmpty else { return 0 }
        let values = memoryMetrics.map { $0.value }
        return values.reduce(0, +) / Double(values.count)
    }

    // MARK: - Connection Indicator
    private var connectionIndicator: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(viewModel.isConnected ? 1.0 : 0.8)
                .animation(.easeInOut, value: viewModel.isConnected)

            Text(viewModel.isConnected ? "Live" : "Disconnected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Supporting Views

@available(macOS 14, iOS 17, *)
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

@available(macOS 14, iOS 17, *)
struct AlertRow: View {
    let alert: ObservabilityCore.Alert

    var body: some View {
        NavigationLink(destination: ErrorDetailView(alert: alert)) {
            HStack(spacing: 12) {
                Image(systemName: severityIcon)
                  .font(.title3)
                  .foregroundColor(severityColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(alert.title)
                      .font(.subheadline)
                      .fontWeight(.semibold)
                      .foregroundColor(.primary)
                      .lineLimit(1)

                    HStack {
                        Text(alert.source.serviceName)
                          .font(.caption)
                          .foregroundColor(.secondary)

                        Text("•")
                          .foregroundColor(.secondary)

                        Text(alert.timestamp, style: .relative)
                          .font(.caption)
                          .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if !alert.acknowledged {
                    Circle()
                      .fill(Color.red)
                      .frame(width: 8, height: 8)
                }
            }
          .padding()
          .background(
                RoundedRectangle(cornerRadius: 8)
                  .fill(Color.secondary.opacity(0.1))
            )
        }
    }
    
    // MARK: - Computed Properties
    private var severityIcon: String {
        switch alert.severity {
        case .info:
            return "info.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        case .critical:
            return "exclamationmark.octagon.fill"
        }
    }
    
    private var severityColor: Color {
        switch alert.severity {
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        case .critical:
            return .red
        }
    }
}
