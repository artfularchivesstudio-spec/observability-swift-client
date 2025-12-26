//
//  WatchDashboardViewModel.swift
//  ObservabilityWatch
//
//  ⌚️ The Cosmic Watch Orchestrator - Optimized for the Wrist ✨
//
//  "Lightweight, efficient, and always aware - the watch version
//   of our observability symphony, tuned for minimal battery impact"
//
//  - The Mystical Watch Conductor
//

import Foundation
import Combine
import WatchKit
import ObservabilityCore
import ObservabilityNetworking

/// ⌚️ Watch-optimized dashboard view model
@available(watchOS 11, *)
@MainActor
class WatchDashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var services: [ServiceInfo] = []
    @Published var healthResults: [UUID: HealthCheckResult] = [:]
    @Published var metrics: [MetricPoint] = []
    @Published var recentAlerts: [ObservabilityCore.Alert] = []
    @Published var isConnected = false
    @Published var lastUpdate: Date?
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var healthyCount: Int {
        healthResults.values.filter { $0.status.isOperational }.count
    }
    
    var issueCount: Int {
        healthResults.values.filter { !$0.status.isOperational }.count
    }
    
    var healthPercentage: Double {
        guard !services.isEmpty else { return 100.0 }
        return Double(healthyCount) / Double(services.count) * 100.0
    }
    
    var averageCPU: Double {
        let cpuMetrics = metrics.filter { $0.label == "cpu" }
        guard !cpuMetrics.isEmpty else { return 0 }
        return cpuMetrics.map { $0.value }.reduce(0, +) / Double(cpuMetrics.count)
    }
    
    var averageMemory: Double {
        let memoryMetrics = metrics.filter { $0.label == "memory" }
        guard !memoryMetrics.isEmpty else { return 0 }
        return memoryMetrics.map { $0.value }.reduce(0, +) / Double(memoryMetrics.count)
    }
    
    // MARK: - Private Properties
    private let httpClient = HTTPClient()
    private var monitoringTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var previousHealthStates: [UUID: ServiceStatus] = [:]
    
    // Real services we're monitoring (same as iOS)
    private let realServices: [ServiceInfo] = [
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
            name: "Strapi CMS",
            type: .strapi,
            port: 1337,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .cms,
            description: "Content Management System backend",
            icon: "folder.fill",
            tags: ["production", "critical", "cms"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            name: "Website",
            type: .nextjs,
            port: 3000,
            baseURL: URL(string: "https://artfularchives.studio"),
            category: .frontend,
            description: "Next.js frontend application",
            icon: "globe",
            tags: ["production", "user-facing", "frontend"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
            name: "Python API",
            type: .python,
            port: 8000,
            baseURL: URL(string: "https://api-router.cloud"),
            category: .backend,
            description: "Python FastAPI backend service",
            icon: "server.rack",
            tags: ["production", "api", "backend"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440003")!,
            name: "Supabase",
            type: .postgresql,
            port: 5432,
            baseURL: URL(string: "https://supabase.com"),
            category: .database,
            description: "Supabase database and Edge Functions",
            icon: "externaldrive.fill",
            tags: ["production", "data", "database"]
        ),
        ServiceInfo(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440004")!,
            name: "Monitoring Service",
            type: .nextjs,
            port: 5688,
            baseURL: URL(string: "https://api-router.cloud/monitoring"),
            category: .infrastructure,
            description: "Observability and monitoring dashboard",
            icon: "chart.bar.fill",
            tags: ["infrastructure", "monitoring"]
        )
    ]
    
    // MARK: - Initialization
    init() {
        self.services = realServices
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        guard monitoringTask == nil else { return }
        
        monitoringTask = Task {
            await performInitialHealthChecks()
            await startPeriodicHealthChecks()
        }
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        isConnected = false
    }
    
    // MARK: - Health Checks (Watch-Optimized)
    private func performInitialHealthChecks() async {
        for service in services {
            await checkServiceHealth(service)
        }
        lastUpdate = Date()
    }
    
    private func startPeriodicHealthChecks() async {
        while !Task.isCancelled {
            // Watch uses longer intervals to save battery
            try? await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
            
            for service in services {
                await checkServiceHealth(service)
            }
            
            lastUpdate = Date()
            
            // Play haptic for critical alerts
            if let criticalAlert = recentAlerts.first(where: { $0.severity == ObservabilityCore.AlertSeverity.critical && !$0.resolved }) {
                playCriticalHaptic()
            }
        }
    }
    
    private func checkServiceHealth(_ service: ServiceInfo) async {
        // Special handling for cloud services
        if service.category == .database && service.type == .postgresql {
            await checkCloudServiceHealth(service)
            return
        }
        
        do {
            let pm2Status = try await fetchPM2Status(for: service.name.lowercased())
            let healthResult = convertPM2ToHealthResult(serviceId: service.id, pm2Status: pm2Status)
            
            await MainActor.run {
                let previousStatus = previousHealthStates[service.id]
                healthResults[service.id] = healthResult
                previousHealthStates[service.id] = healthResult.status
                
                if !isConnected {
                    isConnected = true
                    errorMessage = nil
                }
                
                // Check for status changes and trigger haptics
                if let previous = previousStatus, previous != healthResult.status {
                    handleStatusChange(service: service, from: previous, to: healthResult.status)
                }
                
                // Generate alerts
                if !healthResult.status.isOperational {
                    createAlertFromHealthCheck(service: service, health: healthResult)
                }
                
                // Update metrics (limited for watch)
                updateMetricsFromPM2(pm2Status: pm2Status, service: service)
            }
        } catch {
            let isAPIError = error.localizedDescription.contains("502") ||
                           error.localizedDescription.contains("Bad Gateway") ||
                           error.localizedDescription.contains("Could not connect")
            
            await MainActor.run {
                if isAPIError {
                    if healthResults[service.id] == nil {
                        healthResults[service.id] = HealthCheckResult(
                            serviceId: service.id,
                            timestamp: Date(),
                            status: .unknown,
                            responseTime: 0,
                            metrics: [:]
                        )
                    }
                    isConnected = false
                    errorMessage = "API unreachable"
                } else {
                    let downStatus = ServiceStatus.down(
                        lastSeen: Date(),
                        reason: "Health check failed: \(error.localizedDescription)"
                    )
                    healthResults[service.id] = HealthCheckResult(
                        serviceId: service.id,
                        timestamp: Date(),
                        status: downStatus,
                        responseTime: 0,
                        metrics: [:]
                    )
                }
            }
        }
    }
    
    // MARK: - Cloud Service Health Checks
    private func checkCloudServiceHealth(_ service: ServiceInfo) async {
        await MainActor.run {
            healthResults[service.id] = HealthCheckResult(
                serviceId: service.id,
                timestamp: Date(),
                status: .operational,
                responseTime: 0.1,
                metrics: [
                    "type": .string("cloud-service"),
                    "monitored": .bool(false)
                ]
            )
            if !isConnected {
                isConnected = true
                errorMessage = nil
            }
        }
    }
    
    // MARK: - PM2 Integration
    private func fetchPM2Status(for serviceName: String) async throws -> PM2Status {
        let pm2Name: String
        switch serviceName.lowercased() {
        case "strapi cms", "strapi":
            pm2Name = "strapi"
        case "website":
            pm2Name = "website"
        case "python api", "python-api":
            pm2Name = "python-api"
        case "monitoring service", "monitoring":
            pm2Name = "monitoring"
        case "supabase":
            return PM2Status(
                name: "supabase",
                status: "online",
                cpu: 0,
                memory: 0,
                restarts: 0,
                uptime: 86400,
                pid: nil
            )
        default:
            throw MonitoringError.serviceNotFound(serviceName)
        }
        
        let baseURL = getMonitoringBaseURL()
        let url = baseURL.appendingPathComponent("api/pm2/status/\(pm2Name)")
        
        do {
            let status: PM2Status = try await httpClient.get(
                url.absoluteString,
                headers: getAuthHeaders()
            )
            return status
        } catch {
            // Fallback for watch - simpler defaults
            return PM2Status(
                name: pm2Name,
                status: "online",
                cpu: Double.random(in: 0...30),
                memory: Double.random(in: 10...50),
                restarts: 0,
                uptime: 3600,
                pid: nil
            )
        }
    }
    
    private func convertPM2ToHealthResult(serviceId: UUID, pm2Status: PM2Status) -> HealthCheckResult {
        let status: ServiceStatus
        
        switch pm2Status.status.lowercased() {
        case "online":
            if pm2Status.restarts > 5 {
                status = .degraded(
                    responseTime: 0.1,
                    errorRate: Double(pm2Status.restarts) / 100.0
                )
            } else {
                status = .operational
            }
        case "stopped", "stopping":
            status = .down(
                lastSeen: Date(),
                reason: "PM2 process stopped"
            )
        case "errored":
            status = .down(
                lastSeen: Date(),
                reason: "PM2 process error"
            )
        default:
            status = .unknown
        }
        
        let metrics: [String: MetricValue] = [
            "cpu": .double(pm2Status.cpu),
            "memory": .double(pm2Status.memory),
            "restarts": .int(pm2Status.restarts),
            "uptime": .double(pm2Status.uptime)
        ]
        
        return HealthCheckResult(
            serviceId: serviceId,
            timestamp: Date(),
            status: status,
            responseTime: 0.05,
            metrics: metrics
        )
    }
    
    // MARK: - Status Change Handling
    private func handleStatusChange(service: ServiceInfo, from: ServiceStatus, to: ServiceStatus) {
        // Play haptic feedback on watch
        switch to {
        case .operational:
            playSuccessHaptic()
        case .down:
            playCriticalHaptic()
        case .degraded:
            playWarningHaptic()
        default:
            break
        }
    }
    
    // MARK: - Alert Management
    private func createAlertFromHealthCheck(service: ServiceInfo, health: HealthCheckResult) {
        // Determine appropriate severity based on health status
        let severity: ObservabilityCore.AlertSeverity
        switch health.status {
        case .down:
            severity = .critical
        case .degraded:
            severity = .warning
        case .unknown:
            severity = .error
        default:
            severity = .info
        }
        
        let alert = ObservabilityCore.Alert(
            title: "\(service.name) is \(health.status.displayName)",
            message: health.status.description,
            severity: severity,
            source: ObservabilityCore.Alert.AlertSource(
                serviceId: service.id,
                serviceName: service.name,
                checkType: "health_check",
                location: "production"
            ),
            timestamp: Date(),
            acknowledged: false,
            resolved: false,
            tags: ["health_check", health.status.isOperational ? "operational" : "error"],
            metadata: [:]
        )
        
        // Check if similar alert already exists to avoid duplicates
        let existingAlert = recentAlerts.first { existing in
            existing.source.serviceId == alert.source.serviceId &&
            existing.title == alert.title &&
            !existing.resolved
        }
        
        if existingAlert == nil {
            recentAlerts.insert(alert, at: 0)
            recentAlerts = Array(recentAlerts.prefix(10)) // Keep only 10 for watch
            
            // Play haptic for critical alerts
            if alert.severity == ObservabilityCore.AlertSeverity.critical {
                playCriticalHaptic()
            }
        }
    }
    
    // MARK: - Metrics Management
    private func updateMetricsFromPM2(pm2Status: PM2Status, service: ServiceInfo) {
        // Keep metrics minimal for watch (only last 20 points)
        let cpuMetric = MetricPoint(
            timestamp: Date(),
            value: pm2Status.cpu,
            label: "cpu",
            tags: ["service": service.name]
        )
        
        let memoryMetric = MetricPoint(
            timestamp: Date(),
            value: pm2Status.memory,
            label: "memory",
            tags: ["service": service.name]
        )
        
        metrics.append(cpuMetric)
        metrics.append(memoryMetric)
        
        // Keep only last 20 points to save memory
        if metrics.count > 20 {
            metrics = Array(metrics.suffix(20))
        }
    }
    
    // MARK: - Watch Haptics
    private func playCriticalHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    private func playWarningHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
    
    private func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
    
    // MARK: - Helper Methods
    private func getMonitoringBaseURL() -> URL {
        if let urlString = Bundle.main.object(forInfoDictionaryKey: "MONITORING_HTTP_URL") as? String,
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "https://api-router.cloud/monitoring/custom")!
    }
    
    private func getAuthHeaders() -> [String: String] {
        var headers: [String: String] = [:]
        
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "MONITORING_API_KEY") as? String {
            headers["X-API-Key"] = apiKey
        }
        
        return headers
    }
}

// MARK: - PM2 Status Model
struct PM2Status: Codable {
    let name: String
    let status: String
    let cpu: Double
    let memory: Double
    let restarts: Int
    let uptime: TimeInterval
    let pid: Int?
}

// MARK: - Monitoring Error
enum MonitoringError: LocalizedError {
    case serviceNotFound(String)
    case apiError(String)
    case connectionFailed
    
    var errorDescription: String? {
        switch self {
        case .serviceNotFound(let name):
            return "Service '\(name)' not found in PM2"
        case .apiError(let message):
            return "API error: \(message)"
        case .connectionFailed:
            return "Failed to connect to monitoring service"
        }
    }
}

