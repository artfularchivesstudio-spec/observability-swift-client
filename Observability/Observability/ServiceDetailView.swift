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

/// 🔍 Comprehensive service detail view with metrics, logs, and insights
@available(macOS 14, iOS 17, *)
struct ServiceDetailView: View {
    let service: ServiceInfo
    let health: HealthCheckResult?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ServiceDetailViewModel

    init(service: ServiceInfo, health: HealthCheckResult?) {
        self.service = service
        self.health = health
        _viewModel = StateObject(wrappedValue: ServiceDetailViewModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Status Overview
                statusSection

                // Key Metrics
                if let health = health {
                    metricsSection(health: health)
                }

                // Insights & Recommendations
                insightsSection

                // Recent Logs
                if !viewModel.recentLogs.isEmpty {
                    logsSection
                }

                // Performance Trends
                if !viewModel.metrics.isEmpty {
                    trendsSection
                }
            }
            .padding()
        }
        .navigationTitle(service.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Done") {
                    dismiss()
                }
            }
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
            HStack(alignment: .top, spacing: 16) {
                // Service Icon
                if let icon = service.icon {
                    Image(systemName: icon)
                        .font(.system(size: 48))
                        .foregroundColor(Color(service.category.color))
                        .frame(width: 64, height: 64)
                        .background(
                            Circle()
                                .fill(Color(service.category.color).opacity(0.1))
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(service.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(service.type.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let description = service.description {
                        Text(description)
                            .font(.caption)
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

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    // MARK: - Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
                .foregroundColor(.secondary)

            if let health = health {
                HStack(spacing: 16) {
                    ServiceStatusIndicator(status: health.status)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(health.status.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)

                        Text("Response Time: \(Int(health.responseTime * 1000))ms")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Last Check: \(health.timestamp, format: .relative(presentation: .named))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
            } else {
                HStack {
                    ProgressView()
                    Text("Checking status...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }

    // MARK: - Metrics Section
    private func metricsSection(health: HealthCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Metrics")
                .font(.headline)
                .foregroundColor(.secondary)

            #if os(macOS)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(value))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)

                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights & Recommendations")
                .font(.headline)
                .foregroundColor(.secondary)

            let insights = generateInsights(health: health)
            ForEach(insights, id: \.title) { insight in
                InsightCard(insight: insight)
            }
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
            HStack {
                Text("Recent Logs")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(viewModel.recentLogs.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.recentLogs.prefix(10), id: \.id) { log in
                    LogRow(log: log)
                }
            }
        }
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
        HStack(spacing: 12) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundColor(insight.severity.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(insight.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(insight.severity.color.opacity(0.1))
        )
    }
}

struct LogRow: View {
    let log: StreamEvent

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(logLevelColor)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.data["message"] ?? "No message")
                    .font(.caption.monospaced())
                    .foregroundColor(.primary)
                    .lineLimit(2)

                Text(log.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var logLevelColor: Color {
        switch log.type.lowercased() {
        case "error", "critical": return .red
        case "warn", "warning": return .orange
        case "debug": return .blue
        default: return .gray
        }
    }
}

// MARK: - View Model

@available(macOS 14, iOS 17, *)
@MainActor
class ServiceDetailViewModel: ObservableObject {
    @Published var recentLogs: [StreamEvent] = []
    @Published var metrics: [MetricPoint] = []

    private let service: ServiceInfo
    private let httpClient = HTTPClient()
    private var logStreamTask: Task<Void, Never>?

    init(service: ServiceInfo) {
        self.service = service
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
        // Stream logs filtered by service name
        let baseURL = URL(string: "https://api-router.cloud/monitoring/custom")!
        let url = baseURL.appendingPathComponent("api/logs/stream")
            .appending(queryItems: [
                URLQueryItem(name: "sources", value: service.name.lowercased())
            ])

        let stream = await httpClient.streamEvents(from: url)

        for await event in stream {
            await MainActor.run {
                recentLogs.insert(event, at: 0)
                if recentLogs.count > 100 {
                    recentLogs = Array(recentLogs.prefix(100))
                }
            }
        }
    }
}

