//
//  ServiceDetailView.swift
//  Observability
//
//  🔍 The Cosmic Service Inspector - Where Service Secrets Are Revealed ✨
//
//  "The deep dive into a service's soul, revealing metrics, logs, and insights
//   that illuminate the path to optimal performance"
//
//  - The Mystical Service Analyst
//

import SwiftUI
import Combine
import ObservabilityCore
import ObservabilityNetworking
import ObservabilityUI
#if os(iOS)
import UIKit
#endif

/// 🔍 Comprehensive service detail view with metrics, logs, and insights
@available(macOS 14, iOS 17, *)
public struct ServiceDetailView: View {
    let service: ServiceInfo
    let health: HealthCheckResult?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ServiceDetailViewModel

    public init(service: ServiceInfo, health: HealthCheckResult?) {
        self.service = service
        self.health = health
        _viewModel = StateObject(wrappedValue: ServiceDetailViewModel(service: service))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: platformSpacing) {
                // Header
                headerSection
                    .transition(.move(edge: .top).combined(with: .opacity))

                // Status Overview
                statusSection
                    .transition(.move(edge: .top).combined(with: .opacity))

                // Key Metrics
                if let health = health {
                    metricsSection(health: health)
                        .transition(.scale.combined(with: .opacity))
                }

                // Insights & Recommendations
                insightsSection
                    .transition(.opacity)

                // Recent Logs
                logsSection
                    .transition(.opacity)

                // Performance Trends
                if !viewModel.metrics.isEmpty {
                    trendsSection
                        .transition(.opacity)
                }
            }
            .padding(platformPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .refreshable {
            await viewModel.refreshLogs()
        }
        .navigationTitle(service.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    #if os(iOS)
                    HapticsManager.shared.playSelection()
                    #endif
                    dismiss()
                }
            }
        }
        #else
        .frame(minWidth: 600, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        #endif
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.startMonitoring()
            }
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
    
    // MARK: - Platform-Specific Layout
    private var platformSpacing: CGFloat {
        #if os(macOS)
        return 20
        #else
        return 24
        #endif
    }
    
    private var platformPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 20, leading: 24, bottom: 20, trailing: 24)
        #else
        return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            #if os(macOS)
            HStack(alignment: .top, spacing: 20) {
                serviceIcon
                serviceInfo
                Spacer()
            }
            #else
            HStack(alignment: .top, spacing: 16) {
                serviceIcon
                serviceInfo
            }
            #endif
        }
        .padding(platformCardPadding)
        .background(
            RoundedRectangle(cornerRadius: platformCornerRadius)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private var serviceIcon: some View {
        Group {
            if let icon = service.icon {
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                    .foregroundColor(Color(service.category.color))
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(
                        Circle()
                            .fill(Color(service.category.color).opacity(0.1))
                    )
            }
        }
    }
    
    private var serviceInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(service.name)
                .font(platformTitleFont)
                .fontWeight(.bold)

            Text(service.type.displayName)
                .font(platformSubheadlineFont)
                .foregroundColor(.secondary)

            if let description = service.description {
                Text(description)
                    .font(platformCaptionFont)
                    .foregroundColor(.secondary)
            }

            // Tags
            if !service.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(service.tags), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Platform-Specific Sizing
    private var iconSize: CGFloat {
        #if os(macOS)
        return 40
        #else
        return 48
        #endif
    }
    
    private var iconFrameSize: CGFloat {
        #if os(macOS)
        return 56
        #else
        return 64
        #endif
    }
    
    private var platformTitleFont: Font {
        #if os(macOS)
        return .title2
        #else
        return .title
        #endif
    }
    
    private var platformSubheadlineFont: Font {
        #if os(macOS)
        return .body
        #else
        return .subheadline
        #endif
    }
    
    private var platformCaptionFont: Font {
        #if os(macOS)
        return .subheadline
        #else
        return .caption
        #endif
    }
    
    private var platformCardPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        #else
        return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 12
        #endif
    }

    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(platformHeadlineFont)
                .foregroundColor(.secondary)

            if let health = health {
                Group {
                    #if os(macOS)
                    HStack(spacing: 20) {
                        ServiceStatusIndicator(status: health.status)
                        statusDetails(health: health)
                        Spacer()
                    }
                    #else
                    HStack(spacing: 16) {
                        ServiceStatusIndicator(status: health.status)
                        statusDetails(health: health)
                    }
                    #endif
                }
                .padding(platformCardPadding)
                .background(
                    RoundedRectangle(cornerRadius: platformCornerRadius)
                        .fill(Color.secondary.opacity(0.05))
                )
            } else {
                HStack {
                    ProgressView()
                    Text("Checking status...")
                        .font(platformSubheadlineFont)
                        .foregroundColor(.secondary)
                }
                .padding(platformCardPadding)
            }
        }
    }
    
    private func statusDetails(health: HealthCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(health.status.displayName)
                .font(platformStatusTitleFont)
                .fontWeight(.semibold)

            Text("Response Time: \(Int(health.responseTime * 1000))ms")
                .font(platformCaptionFont)
                .foregroundColor(.secondary)

            Text("Last Check: \(health.timestamp, format: .relative(presentation: .named))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var platformStatusTitleFont: Font {
        #if os(macOS)
        return .title2
        #else
        return .title3
        #endif
    }

    // MARK: - Metrics Section
    private func metricsSection(health: HealthCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(platformHeadlineFont)
                .foregroundColor(.secondary)

            #if os(macOS)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                metricCard(title: "CPU", value: health.metrics["cpu"]?.doubleValue ?? 0, unit: "%", color: .orange)
                metricCard(title: "Memory", value: health.metrics["memory"]?.doubleValue ?? 0, unit: "MB", color: .blue)
                metricCard(title: "Restarts", value: Double(health.metrics["restarts"]?.intValue ?? 0), unit: "", color: .red)
            }
            #else
            VStack(spacing: 12) {
                metricCard(title: "CPU", value: health.metrics["cpu"]?.doubleValue ?? 0, unit: "%", color: .orange)
                metricCard(title: "Memory", value: health.metrics["memory"]?.doubleValue ?? 0, unit: "MB", color: .blue)
                metricCard(title: "Restarts", value: Double(health.metrics["restarts"]?.intValue ?? 0), unit: "", color: .red)
            }
            #endif
        }
    }

    private func metricCard(title: String, value: Double, unit: String, color: Color) -> some View {
        MetricCardView(title: title, value: value, unit: unit, color: color)
    }
    
    private var platformMetricValueFont: Font {
        #if os(macOS)
        return .title3
        #else
        return .title2
        #endif
    }

    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights & Recommendations")
                .font(platformHeadlineFont)
                .foregroundColor(.secondary)

            let insights = generateInsights(health: health)
            #if os(macOS)
            VStack(spacing: 10) {
                ForEach(insights, id: \.title) { insight in
                    InsightCard(insight: insight)
                }
            }
            #else
            VStack(spacing: 8) {
                ForEach(insights, id: \.title) { insight in
                    InsightCard(insight: insight)
                }
            }
            #endif
        }
    }

    private func generateInsights(health: HealthCheckResult?) -> [Insight] {
        var insights: [Insight] = []

        guard let health = health else {
            insights.append(Insight(
                title: "No Health Data",
                message: "Health check data is not available for this service.",
                severity: .info,
                icon: "info.circle"
            ))
            return insights
        }

        // CPU insights
        if let cpu = health.metrics["cpu"]?.doubleValue {
            if cpu > 80 {
                insights.append(Insight(
                    title: "High CPU Usage",
                    message: "CPU usage is \(Int(cpu))%. Consider optimizing or scaling this service.",
                    severity: .warning,
                    icon: "cpu.fill"
                ))
            } else if cpu < 10 {
                insights.append(Insight(
                    title: "Low CPU Usage",
                    message: "CPU usage is only \(Int(cpu))%. This service may be underutilized.",
                    severity: .info,
                    icon: "cpu"
                ))
            }
        }

        // Memory insights
        if let memory = health.metrics["memory"]?.doubleValue {
            if memory > 500 {
                insights.append(Insight(
                    title: "High Memory Usage",
                    message: "Using \(Int(memory))MB of memory. Monitor for potential leaks.",
                    severity: .warning,
                    icon: "memorychip.fill"
                ))
            }
        }

        // Restart insights
        if let restarts = health.metrics["restarts"]?.intValue {
            if restarts > 5 {
                insights.append(Insight(
                    title: "Frequent Restarts",
                    message: "Service has restarted \(restarts) times. Investigate stability issues.",
                    severity: .error,
                    icon: "arrow.clockwise"
                ))
            }
        }

        // Status insights
        switch health.status {
        case .degraded(let responseTime, let errorRate):
            insights.append(Insight(
                title: "Performance Degraded",
                message: "Response time: \(Int(responseTime * 1000))ms, Error rate: \(Int(errorRate * 100))%",
                severity: .warning,
                icon: "exclamationmark.triangle.fill"
            ))
        case .down(let lastSeen, let reason):
            insights.append(Insight(
                title: "Service Down",
                message: "\(reason). Last seen: \(lastSeen.formatted(.relative(presentation: .named)))",
                severity: .error,
                icon: "xmark.circle.fill"
            ))
        default:
            if health.status.isOperational {
                insights.append(Insight(
                    title: "All Systems Operational",
                    message: "Service is running smoothly with no issues detected.",
                    severity: .success,
                    icon: "checkmark.circle.fill"
                ))
            }
        }

        return insights.isEmpty ? [
            Insight(
                title: "No Issues Detected",
                message: "Service appears to be operating normally.",
                severity: .success,
                icon: "checkmark.circle"
            )
        ] : insights
    }

    // MARK: - Logs Section
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with filters
            logsHeaderSection
            
            // Search and filter controls
            if !viewModel.recentLogs.isEmpty {
                logsFilterSection
            }
            
            // Logs list
            if viewModel.filteredLogs.isEmpty && !viewModel.recentLogs.isEmpty {
                noFilteredLogsView
            } else if viewModel.recentLogs.isEmpty {
                emptyLogsView
            } else {
                logsListView
            }
        }
    }
    
    private var logsHeaderSection: some View {
        HStack {
            Text("Recent Logs")
                .font(platformHeadlineFont)
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 8) {
                // Show log source filter indicator
                Text(viewModel.logSourceFilter)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                    .foregroundColor(.blue)
                
                // New log count badge (animated)
                if viewModel.newLogCount > 0 {
                    Text("\(viewModel.newLogCount) new")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.2))
                        )
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
                
                Text("\(viewModel.filteredLogs.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var logsFilterSection: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                TextField("Search logs...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.caption)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        #if os(iOS)
                        HapticsManager.shared.playLightImpact()
                        #endif
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
            )
            
            // Log level filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All button
                    logLevelChip(title: "All", isSelected: viewModel.selectedLogLevel == nil) {
                        #if os(iOS)
                        HapticsManager.shared.playSelection()
                        #endif
                        viewModel.selectedLogLevel = nil
                    }
                    
                    ForEach(viewModel.availableLogLevels, id: \.self) { level in
                        logLevelChip(title: level.capitalized, isSelected: viewModel.selectedLogLevel == level) {
                            #if os(iOS)
                            HapticsManager.shared.playSelection()
                            #endif
                            viewModel.selectedLogLevel = level
                        }
                    }
                }
            }
        }
    }
    
    private func logLevelChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.secondary.opacity(0.1))
                )
                .foregroundColor(isSelected ? .blue : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    private var logsListView: some View {
        #if os(macOS)
        // macOS: Use LazyVStack for better performance with many logs
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.filteredLogs.prefix(logDisplayLimit), id: \.id) { log in
                    LogRow(log: log, isNew: viewModel.logInsertionIds.contains(log.id))
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .frame(maxHeight: 400)
        #else
        // iOS: Regular VStack with swipe actions
        VStack(spacing: 8) {
            ForEach(viewModel.filteredLogs.prefix(logDisplayLimit), id: \.id) { log in
                LogRow(log: log, isNew: viewModel.logInsertionIds.contains(log.id))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            #if os(iOS)
                            HapticsManager.shared.playMediumImpact()
                            #endif
                            // Could implement log deletion or marking as read
                        } label: {
                            Label("Dismiss", systemImage: "xmark.circle")
                        }
                    }
            }
        }
        #endif
    }
    
    private var noFilteredLogsView: some View {
        NoFilteredLogsView()
    }
    
    private var emptyLogsView: some View {
        EmptyLogsView(logSourceFilter: viewModel.logSourceFilter, isRefreshing: viewModel.isRefreshing)
    }
    
    private var platformHeadlineFont: Font {
        #if os(macOS)
        return .title3
        #else
        return .headline
        #endif
    }
    
    private var logDisplayLimit: Int {
        #if os(macOS)
        return 50  // macOS can handle more logs
        #else
        return 20  // iOS: fewer logs for better performance
        #endif
    }

    // MARK: - Trends Section
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance Trends")
                .font(.headline)
                .foregroundColor(.secondary)

            // Simple line chart for CPU
            if let cpuMetrics = viewModel.metrics.filter({ $0.label == "cpu" }).last {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CPU Usage")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(cpuMetrics.value))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Supporting Types

struct Insight: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let severity: InsightSeverity
    let icon: String
}

enum InsightSeverity {
    case success
    case info
    case warning
    case error

    var color: Color {
        switch self {
        case .success: return .green
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        }
    }
}

struct InsightCard: View {
    let insight: Insight

    var body: some View {
        HStack(spacing: insightCardSpacing) {
            Image(systemName: insight.icon)
                .font(insightIconFont)
                .foregroundColor(insight.severity.color)
                .frame(width: insightIconSize)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(insightTitleFont)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(insight.message)
                    .font(insightMessageFont)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(insightCardPadding)
        .background(
            RoundedRectangle(cornerRadius: insightCardCornerRadius)
                .fill(insight.severity.color.opacity(0.1))
        )
    }
    
    // MARK: - Platform-Specific Sizing
    private var insightCardSpacing: CGFloat {
        #if os(macOS)
        return 16
        #else
        return 12
        #endif
    }
    
    private var insightIconSize: CGFloat {
        #if os(macOS)
        return 36
        #else
        return 32
        #endif
    }
    
    private var insightIconFont: Font {
        #if os(macOS)
        return .title2
        #else
        return .title3
        #endif
    }
    
    private var insightTitleFont: Font {
        #if os(macOS)
        return .body
        #else
        return .subheadline
        #endif
    }
    
    private var insightMessageFont: Font {
        #if os(macOS)
        return .subheadline
        #else
        return .caption
        #endif
    }
    
    private var insightCardPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        #else
        return EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        #endif
    }
    
    private var insightCardCornerRadius: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 8
        #endif
    }
}

// MARK: - Animated Metric Card

struct MetricCardView: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    
    @State private var displayedValue: Double = 0
    @State private var isVisible = false
    
    private var platformCaptionFont: Font {
        #if os(macOS)
        return .subheadline
        #else
        return .caption
        #endif
    }
    
    private var platformMetricValueFont: Font {
        #if os(macOS)
        return .title3
        #else
        return .title2
        #endif
    }
    
    private var platformCardPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        #else
        return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 12
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(platformCaptionFont)
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(displayedValue))")
                    .font(platformMetricValueFont)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .contentTransition(.numericText())

                if !unit.isEmpty {
                    Text(unit)
                        .font(platformCaptionFont)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(platformCardPadding)
        .background(
            RoundedRectangle(cornerRadius: platformCornerRadius)
                .fill(color.opacity(0.1))
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
            // Animate value counting up
            withAnimation(.easeOut(duration: 1.0)) {
                displayedValue = value
            }
        }
        .onChange(of: value) { oldValue, newValue in
            // Smooth transition when value changes
            withAnimation(.easeInOut(duration: 0.5)) {
                displayedValue = newValue
            }
        }
    }
}

// MARK: - Empty State Views

struct EmptyLogsView: View {
    let logSourceFilter: String
    let isRefreshing: Bool
    
    @State private var isAnimating = false
    
    private var platformCaptionFont: Font {
        #if os(macOS)
        return .subheadline
        #else
        return .caption
        #endif
    }
    
    private var platformCardPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        #else
        return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 12
        #endif
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if isRefreshing {
                ProgressView()
                    .scaleEffect(1.2)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 48))
                    .symbolEffect(.pulse, isActive: isAnimating)
                    .opacity(isAnimating ? 0.6 : 1.0)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("No logs available")
                    .font(platformCaptionFont)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Logs will appear here when available for \(logSourceFilter)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(platformCardPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: platformCornerRadius)
                .fill(Color.secondary.opacity(0.05))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct NoFilteredLogsView: View {
    @State private var isAnimating = false
    
    private var platformCaptionFont: Font {
        #if os(macOS)
        return .subheadline
        #else
        return .caption
        #endif
    }
    
    private var platformCardPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        #else
        return EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        #endif
    }
    
    private var platformCornerRadius: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 12
        #endif
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundColor(.secondary)
                .font(.title3)
                .symbolEffect(.bounce, value: isAnimating)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("No logs match filters")
                    .font(platformCaptionFont)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Try adjusting your search or log level filter")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(platformCardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: platformCornerRadius)
                .fill(Color.secondary.opacity(0.05))
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }
    }
}

struct LogRow: View {
    let log: StreamEvent
    var isNew: Bool = false
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: logRowSpacing) {
            // Log level indicator with pulse animation for new logs
            ZStack {
                Circle()
                    .fill(logLevelColor)
                    .frame(width: logIndicatorSize, height: logIndicatorSize)
                
                if isNew {
                    Circle()
                        .stroke(logLevelColor, lineWidth: 2)
                        .frame(width: logIndicatorSize + 4, height: logIndicatorSize + 4)
                        .opacity(isVisible ? 0 : 1)
                        .scaleEffect(isVisible ? 1.5 : 1.0)
                }
            }
            .padding(.top, logIndicatorTopPadding)
            .animation(.easeOut(duration: 0.6).repeatCount(2, autoreverses: false), value: isVisible)

            VStack(alignment: .leading, spacing: logRowVerticalSpacing) {
                // Log level badge and source
                HStack(spacing: 8) {
                    Text(log.type.uppercased())
                        .font(logLevelFont)
                        .fontWeight(.semibold)
                        .padding(.horizontal, logBadgeHorizontalPadding)
                        .padding(.vertical, logBadgeVerticalPadding)
                        .background(
                            Capsule()
                                .fill(logLevelColor.opacity(0.2))
                        )
                        .foregroundColor(logLevelColor)
                    
                    // New badge
                    if isNew {
                        Text("NEW")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.3))
                            )
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Source indicator (if different from current filter)
                    if !log.source.isEmpty {
                        Text(log.source)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Log message
                Text(logMessage)
                    .font(logMessageFont)
                    .foregroundColor(.primary)
                    .lineLimit(logMessageLineLimit)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)  // Allow text selection on macOS

                // Timestamp
                HStack(spacing: 4) {
                    Text(log.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    #if os(macOS)
                    Text("• \(log.timestamp.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                    #endif
                }
            }

            Spacer()
        }
        .padding(.vertical, logRowVerticalPadding)
        .padding(.horizontal, logRowHorizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: logRowCornerRadius)
                .fill(isNew ? logLevelColor.opacity(0.15) : logLevelColor.opacity(0.05))
        )
        .scaleEffect(isNew && isVisible ? 1.02 : 1.0)
        .opacity(isVisible ? 1.0 : 0.0)
        #if os(macOS)
        .contentShape(Rectangle())  // Better hover/click handling on macOS
        #endif
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }
            if isNew {
                isVisible = true
            }
        }
    }
    
    // MARK: - Computed Properties
    private var logMessage: String {
        log.data["message"] ?? log.data["text"] ?? "No message"
    }
    
    // MARK: - Platform-Specific Sizing
    private var logRowSpacing: CGFloat {
        #if os(macOS)
        return 12
        #else
        return 8
        #endif
    }
    
    private var logRowVerticalSpacing: CGFloat {
        #if os(macOS)
        return 6
        #else
        return 4
        #endif
    }
    
    private var logIndicatorSize: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 8
        #endif
    }
    
    private var logIndicatorTopPadding: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 6
        #endif
    }
    
    private var logLevelFont: Font {
        #if os(macOS)
        return .caption
        #else
        return .caption2
        #endif
    }
    
    private var logMessageFont: Font {
        #if os(macOS)
        return .system(.caption, design: .monospaced)
        #else
        return .caption.monospaced()
        #endif
    }
    
    private var logMessageLineLimit: Int {
        #if os(macOS)
        return 5  // macOS can show more lines
        #else
        return 3  // iOS: fewer lines for mobile
        #endif
    }
    
    private var logBadgeHorizontalPadding: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 6
        #endif
    }
    
    private var logBadgeVerticalPadding: CGFloat {
        #if os(macOS)
        return 3
        #else
        return 2
        #endif
    }
    
    private var logRowVerticalPadding: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 6
        #endif
    }
    
    private var logRowHorizontalPadding: CGFloat {
        #if os(macOS)
        return 12
        #else
        return 8
        #endif
    }
    
    private var logRowCornerRadius: CGFloat {
        #if os(macOS)
        return 8
        #else
        return 6
        #endif
    }

    private var logLevelColor: Color {
        let level = log.type.lowercased()
        switch level {
        case "error", "critical", "fatal":
            return .red
        case "warn", "warning":
            return .orange
        case "info", "information":
            return .blue
        case "debug", "verbose":
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - View Model

@available(macOS 14, iOS 17, *)
@MainActor
class ServiceDetailViewModel: ObservableObject {
    @Published var recentLogs: [StreamEvent] = []
    @Published var metrics: [MetricPoint] = []
    @Published var logSourceFilter: String = "all"
    @Published var searchText: String = ""
    @Published var selectedLogLevel: String? = nil
    @Published var isRefreshing: Bool = false
    @Published var newLogCount: Int = 0
    
    // Animation state
    @Published var logInsertionIds: Set<UUID> = []

    private let service: ServiceInfo
    private let httpClient = HTTPClient()
    private var logStreamTask: Task<Void, Never>?
    #if os(iOS)
    private let hapticsManager = HapticsManager.shared
    #endif
    
    init(service: ServiceInfo) {
        self.service = service
        self.logSourceFilter = mapServiceToLogSource(service)
    }
    
    /// 🗺️ Map service name/type to backend log source identifier
    /// Converts service names like "Strapi CMS" → "strapi", "Python API" → "python-api"
    private func mapServiceToLogSource(_ service: ServiceInfo) -> String {
        // First, try to match by service name (case-insensitive)
        let serviceNameLower = service.name.lowercased()
        
        switch serviceNameLower {
        case let name where name.contains("strapi"):
            return "strapi"
        case let name where name.contains("website") || name.contains("nextjs"):
            return "website"
        case let name where name.contains("python"):
            return "python-api"
        case let name where name.contains("supabase"):
            return "supabase"
        case let name where name.contains("monitoring"):
            return "monitoring"
        default:
            // Fallback: try to infer from service type
            switch service.type {
            case .strapi:
                return "strapi"
            case .nextjs, .fastify, .nodejs:
                return "website"
            case .python, .django, .flask:
                return "python-api"
            case .postgresql, .redis:
                return serviceNameLower.replacingOccurrences(of: " ", with: "-")
            default:
                // Last resort: use sanitized service name
                return serviceNameLower
                    .replacingOccurrences(of: " ", with: "-")
                    .replacingOccurrences(of: "_", with: "-")
            }
        }
    }

    func startMonitoring() {
        logStreamTask = Task {
            await streamServiceLogs()
        }
    }

    func stopMonitoring() {
        logStreamTask?.cancel()
        logStreamTask = nil
    }

    private func streamServiceLogs() async {
        // 🌟 Map service name/type to log source identifier - The Cosmic Name Translator ✨
        let logSource = mapServiceToLogSource(service)
        
        let baseURL = URL(string: "https://api-router.cloud/monitoring/custom")!
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent("api/logs/stream"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "sources", value: logSource)
        ]
        
        // Add API key if available
        if let apiKey = ProcessInfo.processInfo.environment["MONITORING_API_KEY"] ?? 
                        Bundle.main.object(forInfoDictionaryKey: "MONITORING_API_KEY") as? String {
            urlComponents.queryItems?.append(URLQueryItem(name: "api_key", value: apiKey))
        }
        
        guard let url = urlComponents.url else {
            print("🌩️ Failed to build log stream URL for service: \(service.name)")
            return
        }

        print("🔍 Streaming logs for service '\(service.name)' from source '\(logSource)'")

        let stream = await httpClient.streamEvents(from: url)

        for await event in stream {
            await MainActor.run {
                // 🎭 Animated log insertion with haptic feedback ✨
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    recentLogs.insert(event, at: 0)
                    logInsertionIds.insert(event.id)
                    
                    // Remove insertion ID after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.logInsertionIds.remove(event.id)
                    }
                }
                
                // 📳 Haptic feedback for important log levels (iOS only)
                #if os(iOS)
                let logLevel = event.type.lowercased()
                switch logLevel {
                case "error", "critical", "fatal":
                    hapticsManager.playErrorAlert()
                    newLogCount += 1
                case "warn", "warning":
                    hapticsManager.playWarningAlert()
                default:
                    hapticsManager.playLightImpact()
                }
                #endif
                
                if recentLogs.count > 100 {
                    recentLogs = Array(recentLogs.prefix(100))
                }
            }
        }
    }
    
    // MARK: - Filtering
    var filteredLogs: [StreamEvent] {
        var logs = recentLogs
        
        // Filter by log level
        if let level = selectedLogLevel {
            logs = logs.filter { $0.type.lowercased() == level.lowercased() }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            logs = logs.filter { log in
                let message = log.data["message"] ?? log.data["text"] ?? ""
                return message.localizedCaseInsensitiveContains(searchText) ||
                       log.source.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return logs
    }
    
    var availableLogLevels: [String] {
        Array(Set(recentLogs.map { $0.type.lowercased() })).sorted()
    }
    
    func refreshLogs() async {
        isRefreshing = true
        newLogCount = 0
        // Restart streaming
        stopMonitoring()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        startMonitoring()
        isRefreshing = false
    }
}

