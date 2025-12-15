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
    @State private var selectedFilter: ServiceStatus? = nil
    @State private var searchText = ""

    var body: some View {
        NavigationView {
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
            }
            .navigationTitle("Infrastructure Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    connectionIndicator
                }
            }
            .onAppear {
                viewModel.startMonitoring()
            }
            .onDisappear {
                viewModel.stopMonitoring()
            }
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

                    ForEach(ServiceStatus.allCases, id: \.self) { status in
                        let count = viewModel.services.filter { service in
                            guard let health = viewModel.healthResults[service.id] else { return false }
                            return health.status == status
                        }.count

                        StatusFilterButton(
                            label: status.displayName,
                            count: count,
                            isSelected: selectedFilter == status
                        ) {
                            selectedFilter = status
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
                    showingAlertDetail = true
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

            // Line Chart
            MetricChart(
                title: "CPU Trend",
                metricsPublisher: Just(viewModel.metrics.last ?? MetricPoint(value: 0, label: "cpu")).eraseToAnyPublisher(),
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
        return cpuMetrics.map { $0.value }.average()
    }

    private var averageMemory: Double {
        let memoryMetrics = viewModel.metrics.filter { $0.label == "memory" }
        guard !memoryMetrics.isEmpty else { return 0 }
        return memoryMetrics.map { $0.value }.average()
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
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

@available(macOS 14, iOS 17, *)
struct AlertRow: View {
    let alert: Alert

    var body: some View {
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
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var severityIcon: String {
        switch alert.severity {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }

    private var severityColor: Color {
        switch alert.severity {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .critical: return .red
        }
    }
}

// MARK: - ServiceStatus Cases

extension ServiceStatus {
    var displayName: String {
        switch self {
        case .operational: return "Operational"
        case .degraded: return "Degraded"
        case .down: return "Down"
        case .maintenance: return "Maintenance"
        case .unknown: return "Unknown"
        }
    }

    static var allCases: [ServiceStatus] {
        [
            .operational,
            .degraded(responseTime: 0.1, errorRate: 0.01),
            .down(lastSeen: Date(), reason: "Unknown"),
            .maintenance(scheduledUntil: Date().addingTimeInterval(3600)),
            .unknown
        ]
    }
}

// MARK: - Dashboard View Model

@available(macOS 14, iOS 17, *)
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var services: [ServiceInfo] = PreviewData.sampleServices
    @Published var healthResults: [UUID: HealthCheckResult] = [:]
    @Published var metrics: [MetricPoint] = []
    @Published var recentAlerts: [Alert] = PreviewData.sampleAlerts
    @Published var isConnected = false

    private var webSocketClient = WebSocketCombineClient()
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?

    var healthyCount: Int {
        healthResults.values.filter { $0.status.isOperational }.count
    }

    var issueCount: Int {
        healthResults.values.filter { !$0.status.isOperational }.count
    }

    var activeAlertsCount: Int {
        recentAlerts.filter { !$0.acknowledged }.count
    }

    func startMonitoring() {
        // Connect to live observability server with API key auth
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "MONITORING_API_KEY") as? String else {
            print("❌ API Key not found in Info.plist. Run setup-monitoring-api-key.sh first!")
            startSimulatedMonitoring()
            return
        }

        guard var urlComponents = URLComponents(string: "wss://api-router.cloud/monitoring/custom/") else {
            print("❌ Invalid WebSocket URL")
            return
        }

        // Add API key as query parameter (WebSocket doesn't support headers consistently)
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        guard let url = urlComponents.url else {
            print("❌ Failed to construct WebSocket URL with API key")
            return
        }

        Task {
            do {
                try await webSocketClient.connect(to: url)
                isConnected = true
                print("✅ Connected to live observability server")

                // Subscribe to real-time metrics
                webSocketClient.metricPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] metric in
                        self?.metrics.append(metric)

                        // Keep only last 100 points
                        if self?.metrics.count ?? 0 > 100 {
                            self?.metrics.removeFirst((self?.metrics.count ?? 0) - 100)
                        }
                    }
                    .store(in: &cancellables)

                // Subscribe to health events
                webSocketClient.healthPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] health in
                        self?.healthResults[health.serviceId] = health
                    }
                    .store(in: &cancellables)

                // Subscribe to events
                webSocketClient.eventPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] event in
                        if event.type == "alert" {
                            self?.handleAlertEvent(event)
                        }
                    }
                    .store(in: &cancellables)

            } catch {
                print("❌ Failed to connect: \(error.localizedDescription)")
                isConnected = false
                // Fall back to simulated data
                startSimulatedMonitoring()
            }
        }
    }

    private func startSimulatedMonitoring() {
        // Fallback simulation if live server fails
        print("⚠️ Using simulated data - connecting to live server failed")
        isConnected = false

        // Populate with sample services
        services = [
            ServiceInfo(name: "Strapi CMS", type: .strapi, port: 1337, category: .cms),
            ServiceInfo(name: "Next.js Frontend", type: .nextjs, port: 3000, category: .frontend),
            ServiceInfo(name: "Python API", type: .flask, port: 8000, category: .backend),
            ServiceInfo(name: "PostgreSQL", type: .postgresql, port: 5432, category: .database),
            ServiceInfo(name: "Redis Cache", type: .redis, port: 6379, category: .infrastructure)
        ]

        startHealthChecks()
        startMetricsCollection()
        simulateAlerts()
    }

    private func handleAlertEvent(_ event: StreamEvent) {
        // Try to decode alert from event data
        if let jsonString = event.data["payload"],
           let jsonData = jsonString.data(using: .utf8) {
            do {
                let alert = try JSONDecoder().decode(Alert.self, from: jsonData)

                // Add to recent alerts
                recentAlerts.insert(alert, at: 0)

                // Keep only last 10 alerts
                if recentAlerts.count > 10 {
                    recentAlerts.removeLast(recentAlerts.count - 10)
                }

            } catch {
                print("❌ Failed to decode alert from event: \(error)")
            }
        }
    }

    func stopMonitoring() {
        isConnected = false
        refreshTimer?.invalidate()
        cancellables.removeAll()
    }

    private func startHealthChecks() {
        // Simulate health check every 10 seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                for service in self.services {
                    let health = PreviewData.sampleHealth(for: service.id)
                    self.healthResults[service.id] = health
                }
            }
        }

        // Initial check
        Task { @MainActor in
            for service in services {
                let health = PreviewData.sampleHealth(for: service.id)
                healthResults[service.id] = health
            }
        }
    }

    private func startMetricsCollection() {
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                let metrics = [
                    MetricPoint(value: Double.random(in: 0...100), label: "cpu"),
                    MetricPoint(value: Double.random(in: 0...100), label: "memory"),
                    MetricPoint(value: Double.random(in: 0...100), label: "disk"),
                    MetricPoint(value: Double.random(in: 0...10000), label: "network")
                ]

                self.metrics.append(contentsOf: metrics)

                // Keep only last 100 points
                if self.metrics.count > 100 {
                    self.metrics.removeFirst(self.metrics.count - 100)
                }
            }
            .store(in: &cancellables)
    }

    private func simulateAlerts() {
        // Simulate incoming alerts
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                if Double.random(in: 0...1) > 0.7 {
                    let newAlert = Alert(
                        title: "Random Alert #\(Int.random(in: 100...999))",
                        message: "This is a simulated alert",
                        severity: [.info, .warning, .error, .critical].randomElement()!,
                        source: Alert.AlertSource(
                            serviceName: PreviewData.sampleServices.randomElement()!.name,
                            checkType: "random_check"
                        ),
                        tags: ["simulated"]
                    )

                    self.recentAlerts.insert(newAlert, at: 0)

                    // Keep only last 10 alerts
                    if self.recentAlerts.count > 10 {
                        self.recentAlerts.removeLast(self.recentAlerts.count - 10)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Xcode Previews

@available(macOS 14, iOS 17, *)
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // iPhone Sizes
            DashboardView()
                .previewDisplayName("iPhone 15 Pro")

            DashboardView()
                .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
                .previewDisplayName("iPhone SE")

            // iPad Sizes
            DashboardView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
                .previewDisplayName("iPad Pro")

            // Light/Dark Modes
            DashboardView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")

            // macOS
            DashboardView()
                .previewLayout(.fixed(width: 1200, height: 800))
                .previewDisplayName("macOS")
        }
    }
}
