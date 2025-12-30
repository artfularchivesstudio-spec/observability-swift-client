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
    @State private var selectedLogEntry: ServerLogEntry?

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

                // Server Logs (with 500 error tracking + NGINX Config)
                serverLogsSection
            }
            .padding()
            .frame(maxWidth: .infinity)
            #if os(macOS)
            .frame(maxWidth: 1400) // Prevent content from being too wide on large screens
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Infrastructure Dashboard")
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
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎭 Infrastructure Observatory")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)

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

                    // Operational filter
                    let operationalCount = viewModel.services.filter { service in
                        guard let health = viewModel.healthResults[service.id] else { return false }
                        return health.status.isOperational
                    }.count
                    
                    StatusFilterButton(
                        label: "Operational",
                        count: operationalCount,
                        isSelected: false
                    ) {
                        // Filter would be set here if we implement custom filter logic
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
        .sheet(item: $selectedService) { service in
            NavigationStack {
                ServiceDetailView(
                    service: service,
                    health: viewModel.healthResults[service.id]
                )
            }
            #if os(macOS)
            .frame(minWidth: 600, minHeight: 500)
            .onTapGesture {
                // Allow dismissing by clicking outside (macOS behavior)
            }
            #endif
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

    // MARK: - NGINX Config Section
    private var nginxConfigSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("NGINX Configuration")
                    .font(.title2)
                    .fontWeight(.semibold)
                
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
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
                }
                .disabled(viewModel.isLoadingNginxConfig)
            }
            
            if let config = viewModel.nginxConfig {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(config)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 400)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                )
            } else if viewModel.isLoadingNginxConfig {
                HStack {
                    ProgressView()
                    Text("Loading nginx configuration from hostinger-vps...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No nginx configuration loaded")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Click 'Refresh' to fetch from hostinger-vps server")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
            }
        }
    }
    
    // MARK: - Server Logs Section
    private var serverLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Server Logs")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // 500 Errors Badge
                if viewModel.serverLogs.error500Entries.count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("\(viewModel.serverLogs.error500Entries.count) 500 Errors")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(6)
                }
                
                // Filter Toggle
                Toggle(isOn: $viewModel.showOnly500Errors) {
                    Text("500s Only")
                        .font(.caption)
                }
                .toggleStyle(.switch)
                .scaleEffect(0.8)
                
                // Refresh Button
                Button(action: {
                    Task {
                        await viewModel.refreshServerLogs()
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
            
            if viewModel.isLoadingLogs && viewModel.serverLogs.entries.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading server logs from hostinger-vps...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                let displayedLogs = viewModel.showOnly500Errors
                    ? viewModel.serverLogs.error500Entries
                    : Array(viewModel.serverLogs.entries.prefix(100)) // Show last 100 entries
                
                if displayedLogs.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: viewModel.showOnly500Errors ? "checkmark.circle" : "doc.text")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.showOnly500Errors 
                             ? "No 500 errors found in recent logs 🎉"
                             : "No log entries available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if viewModel.showOnly500Errors {
                            Text("Great! Your server is responding successfully")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.05))
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(displayedLogs), id: \.id) { logEntry in
                                LogEntryRow(logEntry: logEntry) {
                                    selectedLogEntry = logEntry
                                }
                            }
                            
                            // Load More button
                            if viewModel.hasMoreLogs && !viewModel.isLoadingMoreLogs {
                                Button(action: {
                                    Task {
                                        await viewModel.loadMoreLogs()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle")
                                        Text("Load More Logs")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if viewModel.isLoadingMoreLogs {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Loading more logs...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 500)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.05))
                    )
                    .sheet(item: $selectedLogEntry) { logEntry in
                        NavigationStack {
                            LogDetailView(logEntry: logEntry)
                        }
                        #if os(macOS)
                        .frame(minWidth: 700, minHeight: 600)
                        .onTapGesture {
                            // Allow dismissing by clicking outside (macOS behavior)
                        }
                        #endif
                    }
                }
            }
            
            // Summary Stats
            if !viewModel.serverLogs.entries.isEmpty {
                HStack(spacing: 16) {
                    StatBadge(
                        label: "Total Logs",
                        value: "\(viewModel.serverLogs.entries.count)",
                        color: .blue
                    )

                    StatBadge(
                        label: "500 Errors",
                        value: "\(viewModel.serverLogs.error500Entries.count)",
                        color: .red
                    )

                    StatBadge(
                        label: "Last Updated",
                        value: viewModel.serverLogs.fetchedAt.formatted(date: .omitted, time: .shortened),
                        color: .secondary
                    )
                }
                .font(.caption)
            }

            // 🌐 NGINX Configuration Subsection - The Gateway Guardian's Scroll 📜
            Divider()
                .padding(.vertical, 8)

            nginxConfigSubsection
        }
    }

    // MARK: - NGINX Config Subsection (embedded in Server Logs)
    /// 🌐 The NGINX Configuration viewer - nestled within the Server Logs section like a scroll within the grand archive ✨
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(config)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.primary)
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    Text("Loading nginx configuration from hostinger-vps...")
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

                    Text("NGINX config loads automatically on launch")
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

    // MARK: - Connection Indicator
    private var connectionIndicator: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                    .scaleEffect(viewModel.isConnected ? 1.0 : 0.8)
                    .animation(.easeInOut, value: viewModel.isConnected)

                Text(viewModel.isConnected ? "Live" : "Offline")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let error = viewModel.connectionError {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 200, alignment: .trailing)
            }
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

/// 📜 Log entry row view - Displaying individual log entries with style
@available(macOS 14, iOS 17, *)
struct LogEntryRow: View {
    let logEntry: ServerLogEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
        HStack(alignment: .top, spacing: 12) {
            // Log level indicator
            Circle()
                .fill(levelColor)
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    // Status code badge for HTTP errors
                    if let statusCode = logEntry.statusCode {
                        Text("\(statusCode)")
                            .font(.caption2.monospaced())
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(statusCodeColor(statusCode))
                            .cornerRadius(3)
                    }
                    
                    // Request method
                    if let method = logEntry.requestMethod {
                        Text(method)
                            .font(.caption2.monospaced())
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    // Request path
                    if let path = logEntry.requestPath {
                        Text(path)
                            .font(.caption2.monospaced())
                            .foregroundColor(.primary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    // Timestamp
                    Text(logEntry.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Message (full, no truncation)
                Text(logEntry.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Additional details
                if let clientIP = logEntry.clientIP {
                    HStack(spacing: 4) {
                        Image(systemName: "network")
                            .font(.caption2)
                        Text(clientIP)
                            .font(.caption2.monospaced())
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(logEntry.is500Error ? Color.red.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(logEntry.is500Error ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
    
    private var levelColor: Color {
        switch logEntry.level {
        case .debug:
            return .gray
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
    
    private func statusCodeColor(_ code: Int) -> Color {
        switch code {
        case 200...299:
            return .green
        case 300...399:
            return .blue
        case 400...499:
            return .orange
        case 500...599:
            return .red
        default:
            return .gray
        }
    }
}

/// 📊 Stat badge component for log statistics
@available(macOS 14, iOS 17, *)
struct StatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
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
