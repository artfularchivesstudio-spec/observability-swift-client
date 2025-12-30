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
public struct DashboardView: View {
    // MARK: - State
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedService: ServiceInfo?
    @State private var showingAlertDetail = false

    // MARK: - Filter State
    @State private var selectedFilter: ServiceStatus?
    @State private var searchText = ""

    // MARK: - Collapsible Section State 📦
    @State private var statsExpanded = false      // Stats bar collapsed by default
    @State private var metricsExpanded = false    // Live Metrics collapsed by default

    public init() {}

    public var body: some View {
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

                // Server Logs (with NGINX Config nested inside) 📜
                serverLogsSection
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
                HStack {
                    connectionIndicator
                    #if DEBUG
                    Menu {
                        Button("Test Critical Alert") {
                            Task {
                                await viewModel.testSendNotification(type: DashboardViewModel.NotificationTestType.critical)
                            }
                        }
                        Button("Test Error Alert") {
                            Task {
                                await viewModel.testSendNotification(type: DashboardViewModel.NotificationTestType.error)
                            }
                        }
                        Button("Test Warning Alert") {
                            Task {
                                await viewModel.testSendNotification(type: DashboardViewModel.NotificationTestType.warning)
                            }
                        }
                        Button("Test Status Change") {
                            Task {
                                await viewModel.testSendNotification(type: DashboardViewModel.NotificationTestType.statusChange)
                            }
                        }
                    } label: {
                        Image(systemName: "bell.badge")
                            .foregroundColor(.blue)
                    }
                    #endif
                }
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

            // Collapsible Stats Bar 📊
            VStack(spacing: 0) {
                // Compact header bar - always visible
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        statsExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 16) {
                        // Compact inline stats
                        HStack(spacing: 12) {
                            MiniStatBadge(value: viewModel.services.count, icon: "server.rack", color: .blue)
                            MiniStatBadge(value: viewModel.healthyCount, icon: "checkmark.circle.fill", color: .green)
                            MiniStatBadge(value: viewModel.issueCount, icon: "exclamationmark.triangle.fill", color: .orange)
                            MiniStatBadge(value: viewModel.activeAlertsCount, icon: "bell.badge.fill", color: .red)
                        }

                        Spacer()

                        // Expand/collapse indicator
                        HStack(spacing: 4) {
                            Text(statsExpanded ? "Less" : "More")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .rotationEffect(.degrees(statsExpanded ? 90 : 0))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.secondary.opacity(0.1))
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Expanded stats cards
                if statsExpanded {
                    #if os(macOS)
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        StatCard(title: "Services", value: "\(viewModel.services.count)", icon: "server.rack", color: .blue)
                        StatCard(title: "Healthy", value: "\(viewModel.healthyCount)", icon: "checkmark.circle.fill", color: .green)
                        StatCard(title: "Issues", value: "\(viewModel.issueCount)", icon: "exclamationmark.triangle.fill", color: .orange)
                        StatCard(title: "Alerts", value: "\(viewModel.activeAlertsCount)", icon: "bell.badge.fill", color: .red)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    #else
                    HStack(spacing: 20) {
                        StatCard(title: "Services", value: "\(viewModel.services.count)", icon: "server.rack", color: .blue)
                        StatCard(title: "Healthy", value: "\(viewModel.healthyCount)", icon: "checkmark.circle.fill", color: .green)
                        StatCard(title: "Issues", value: "\(viewModel.issueCount)", icon: "exclamationmark.triangle.fill", color: .orange)
                        StatCard(title: "Alerts", value: "\(viewModel.activeAlertsCount)", icon: "bell.badge.fill", color: .red)
                    }
                    .padding(.top, 12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    #endif
                }
            }
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

    // MARK: - Metrics Section (Collapsible) 📈
    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapsible header bar with inline CPU/Memory preview
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    metricsExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.body)
                        .foregroundColor(.cyan)

                    Text("Live Metrics")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    // Inline mini metrics preview
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("CPU")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(averageCPU))%")
                                .font(.caption.monospaced())
                                .fontWeight(.semibold)
                                .foregroundColor(averageCPU > 80 ? .red : averageCPU > 50 ? .orange : .green)
                        }

                        HStack(spacing: 4) {
                            Text("MEM")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("\(Int(averageMemory))%")
                                .font(.caption.monospaced())
                                .fontWeight(.semibold)
                                .foregroundColor(averageMemory > 80 ? .red : averageMemory > 50 ? .orange : .yellow)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.secondary.opacity(0.1))
                    )

                    Spacer()

                    // Expand/collapse indicator
                    HStack(spacing: 4) {
                        Text(metricsExpanded ? "Less" : "More")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(metricsExpanded ? 90 : 0))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.1))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Expanded metrics content
            if metricsExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    #if os(macOS)
                    HStack(spacing: 16) {
                        MetricGauge(title: "CPU", value: averageCPU, minValue: 0, maxValue: 100, unit: "%")
                            .frame(maxWidth: .infinity)
                        MetricGauge(title: "Memory", value: averageMemory, minValue: 0, maxValue: 100, unit: "%")
                            .frame(maxWidth: .infinity)
                    }
                    #else
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MetricGauge(title: "CPU", value: averageCPU, minValue: 0, maxValue: 100, unit: "%")
                        MetricGauge(title: "Memory", value: averageMemory, minValue: 0, maxValue: 100, unit: "%")
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
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
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

    // MARK: - Server Logs Section 📜
    /// 📜 The Server Logs section - cosmic archive with NGINX config nested inside
    private var serverLogsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with refresh button
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.blue)
                    Text("Server Logs")
                        .font(.title2)
                        .fontWeight(.semibold)
                }

                Spacer()

                // 500 Error Badge
                if viewModel.serverLogs.error500Entries.count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("\(viewModel.serverLogs.error500Entries.count) 500 Errors")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }

                Button(action: {
                    Task {
                        await viewModel.fetchServerLogs()
                    }
                }) {
                    HStack(spacing: 4) {
                        if viewModel.isLoadingLogs {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        Text("Refresh")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
                .disabled(viewModel.isLoadingLogs)
            }

            // Log entries
            if viewModel.serverLogs.entries.isEmpty && !viewModel.isLoadingLogs {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No logs yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Logs will appear here when fetched")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else if viewModel.isLoadingLogs && viewModel.serverLogs.entries.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading logs...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                // Log list - each row is tappable to show details 🔍
                LazyVStack(spacing: 4) {
                    ForEach(viewModel.serverLogs.entries.prefix(20)) { entry in
                        NavigationLink(destination: LogDetailView(logEntry: entry)) {
                            ServerLogRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
            }

            // Stats summary
            if !viewModel.serverLogs.entries.isEmpty {
                HStack(spacing: 16) {
                    Label("\(viewModel.serverLogs.entries.count) Total", systemImage: "doc.text")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Label("\(viewModel.serverLogs.error500Entries.count) Errors", systemImage: "exclamationmark.circle")
                        .font(.caption)
                        .foregroundColor(.red)

                    Spacer()

                    Text("Updated: \(viewModel.serverLogs.fetchedAt.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // NGINX Config subsection (nested inside Server Logs) 🌐
            Divider()
                .padding(.vertical, 8)

            nginxConfigSubsection
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.05))
        )
        .task {
            await viewModel.fetchServerLogs()
            await viewModel.fetchNginxConfig()
        }
    }

    // MARK: - NGINX Config Subsection 🌐
    /// 🌐 NGINX Configuration viewer - nested within Server Logs
    private var nginxConfigSubsection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "network")
                        .foregroundColor(.purple)
                    Text("NGINX Configuration")
                        .font(.headline)
                        .fontWeight(.semibold)
                }

                Spacer()

                Button(action: {
                    Task {
                        await viewModel.refreshNginxConfig()
                    }
                }) {
                    HStack(spacing: 4) {
                        if viewModel.isLoadingNginxConfig {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                        }
                        Text("Refresh")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(6)
                }
                .disabled(viewModel.isLoadingNginxConfig)
            }

            if let config = viewModel.nginxConfig {
                ScrollView {
                    Text(config)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(maxHeight: 300)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                        )
                )
            } else if viewModel.isLoadingNginxConfig {
                HStack {
                    ProgressView()
                    Text("Loading NGINX config...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("NGINX config will load automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
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

/// 📊 MiniStatBadge - Compact stat display for collapsed header bar
/// Shows icon + value in a tiny space - perfect for the "at a glance" vibe 👀
@available(macOS 14, iOS 17, *)
struct MiniStatBadge: View {
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text("\(value)")
                .font(.caption.monospaced())
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
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

// MARK: - Server Log Row 📜
/// 📜 ServerLogRow - A single line in the cosmic archive of infrastructure whispers
/// Each entry tells a tale of requests, responses, and the occasional 500 error tantrum 🎭
@available(macOS 14, iOS 17, *)
struct ServerLogRow: View {
    let entry: ServerLogEntry

    var body: some View {
        HStack(spacing: 8) {
            // Level indicator - the mood ring of logs 🔮
            Circle()
                .fill(levelColor)
                .frame(width: 8, height: 8)

            // Timestamp - when the magic happened ⏰
            Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)

            // Source badge - where the whisper originated 🏷️
            Text(entry.source)
                .font(.system(.caption2, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(sourceColor.opacity(0.2))
                )
                .foregroundColor(sourceColor)

            // Status code badge (if present) - the HTTP fortune cookie 🥠
            if let statusCode = entry.statusCode {
                Text("\(statusCode)")
                    .font(.system(.caption2, design: .monospaced))
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(statusCodeColor(statusCode).opacity(0.2))
                    )
                    .foregroundColor(statusCodeColor(statusCode))
            }

            // Message - the actual cosmic whisper 💬
            Text(entry.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(levelColor.opacity(0.05))
        )
    }

    // MARK: - Computed Properties

    /// 🎨 Level color - painting logs with emotional hues
    private var levelColor: Color {
        switch entry.level.lowercased() {
        case "error":
            return .red
        case "warning":
            return .orange
        case "info":
            return .blue
        case "debug":
            return .gray
        default:
            return .secondary
        }
    }

    /// 🏷️ Source color - each service gets its own aura
    private var sourceColor: Color {
        switch entry.source.lowercased() {
        case "nginx":
            return .green
        case "strapi":
            return .purple
        case "next.js", "nextjs":
            return .blue
        case "python-api", "python":
            return .yellow
        case "monitoring":
            return .cyan
        default:
            return .gray
        }
    }

    /// 🥠 Status code color - HTTP fortune telling by numbers
    private func statusCodeColor(_ code: Int) -> Color {
        switch code {
        case 200..<300:
            return .green
        case 300..<400:
            return .blue
        case 400..<500:
            return .orange
        case 500..<600:
            return .red
        default:
            return .gray
        }
    }
}
