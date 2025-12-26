//
//  ServiceStatus.swift
//  ObservabilityCore
//
//  🎭 The Cosmic Service State Enumerations - Where Digital Entities Reveal Their Vital Signs ✨
//

import Foundation

/// 🌟 Service health status with rich associated data
@available(macOS 14, iOS 17, *)
public enum ServiceStatus: Sendable, Codable, Equatable {
    // MARK: - Primary States
    case operational
    case degraded(responseTime: TimeInterval, errorRate: Double)
    case down(lastSeen: Date, reason: String)
    case maintenance(scheduledUntil: Date)
    case unknown

    // MARK: - Computed Properties
    public var isOperational: Bool {
        switch self {
        case .operational:
            return true
        default:
            return false
        }
    }

    public var severity: AlertSeverity {
        switch self {
        case .operational:
            return .info
        case .degraded:
            return .warning
        case .down:
            return .critical
        case .maintenance:
            return .info
        case .unknown:
            return .error
        }
    }

    public var displayName: String {
        switch self {
        case .operational:
            return "Operational"
        case .degraded:
            return "Degraded"
        case .down:
            return "Down"
        case .maintenance:
            return "Maintenance"
        case .unknown:
            return "Unknown"
        }
    }

    public var description: String {
        switch self {
        case .operational:
            return "All systems operational"
        case .degraded(let responseTime, let errorRate):
            return "Performance degraded: \(Int(responseTime * 1000))ms, \(Int(errorRate * 100))% errors"
        case .down(let lastSeen, let reason):
            let interval = Date().timeIntervalSince(lastSeen)
            let timeString: String
            if interval < 3600 {
                let minutes = Int(interval / 60)
                timeString = "\(minutes)\(minutes == 1 ? "m" : "m") ago"
            } else if interval < 86400 {
                let hours = Int(interval / 3600)
                timeString = "\(hours)\(hours == 1 ? "h" : "h") ago"
            } else {
                let days = Int(interval / 86400)
                timeString = "\(days)\(days == 1 ? "d" : "d") ago"
            }
            return "Service down since \(timeString): \(reason)"
        case .maintenance(let scheduledUntil):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return "Under maintenance until \(formatter.string(from: scheduledUntil))"
        case .unknown:
            return "Status unknown - connectivity issues"
        }
    }
}

/// 🎨 Service identification with metadata
@available(macOS 14, iOS 17, *)
public struct ServiceInfo: Sendable, Codable, Identifiable, Equatable {
    public let id: UUID
    public var name: String
    public var type: ServiceType
    public var port: Int?
    public var baseURL: URL?
    public var category: ServiceCategory
    public var description: String?
    public var icon: String?
    public var tags: Set<String>

    public init(
        id: UUID = UUID(),
        name: String,
        type: ServiceType,
        port: Int? = nil,
        baseURL: URL? = nil,
        category: ServiceCategory,
        description: String? = nil,
        icon: String? = nil,
        tags: Set<String> = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.port = port
        self.baseURL = baseURL
        self.category = category
        self.description = description
        self.icon = icon
        self.tags = tags
    }

    public enum ServiceType: String, Sendable, Codable, CaseIterable {
        case strapi
        case nextjs
        case fastify
        case django
        case flask
        case nodejs
        case python
        case swift
        case postgresql
        case redis
        case nginx
        case custom

        public var displayName: String {
            switch self {
            case .strapi: return "Strapi"
            case .nextjs: return "Next.js"
            case .fastify: return "Fastify"
            case .django: return "Django"
            case .flask: return "Flask"
            case .nodejs: return "Node.js"
            case .python: return "Python"
            case .swift: return "Swift"
            case .postgresql: return "PostgreSQL"
            case .redis: return "Redis"
            case .nginx: return "NGINX"
            case .custom: return "Custom"
            }
        }
    }

    public enum ServiceCategory: String, Sendable, Codable, CaseIterable {
        case cms
        case frontend
        case backend
        case database
        case infrastructure
        case monitoring
        case api
        case storage
        case auth

        public var displayName: String {
            switch self {
            case .cms: return "CMS"
            case .frontend: return "Frontend"
            case .backend: return "Backend"
            case .database: return "Database"
            case .infrastructure: return "Infrastructure"
            case .monitoring: return "Monitoring"
            case .api: return "API"
            case .storage: return "Storage"
            case .auth: return "Authentication"
            }
        }

        public var color: String {
            switch self {
            case .cms: return "#3498db"
            case .frontend: return "#e74c3c"
            case .backend: return "#2ecc71"
            case .database: return "#f39c12"
            case .infrastructure: return "#9b59b6"
            case .monitoring: return "#1abc9c"
            case .api: return "#e67e22"
            case .storage: return "#34495e"
            case .auth: return "#e91e63"
            }
        }
    }
}

/// 📊 Service health check result
@available(macOS 14, iOS 17, *)
public struct HealthCheckResult: Sendable, Codable {
    public let serviceId: UUID
    public let timestamp: Date
    public let status: ServiceStatus
    public let responseTime: TimeInterval
    public let metrics: [String: MetricValue]
    public let checks: [String: CheckResult]

    public init(
        serviceId: UUID,
        timestamp: Date = Date(),
        status: ServiceStatus,
        responseTime: TimeInterval,
        metrics: [String: MetricValue] = [:],
        checks: [String: CheckResult] = [:]
    ) {
        self.serviceId = serviceId
        self.timestamp = timestamp
        self.status = status
        self.responseTime = responseTime
        self.metrics = metrics
        self.checks = checks
    }

    public enum CheckResult: Sendable, Codable {
        case passed
        case failed(ErrorInfo)
        case warning(String)

        public var isSuccess: Bool {
            switch self {
            case .passed:
                return true
            case .failed, .warning:
                return false
            }
        }
    }

    public struct ErrorInfo: Sendable, Codable {
        public let code: String
        public let message: String
        public let details: [String: String]?

        public init(code: String, message: String, details: [String: String]? = nil) {
            self.code = code
            self.message = message
            self.details = details
        }
    }
}

/// 📈 Universal metric value type
@available(macOS 14, iOS 17, *)
public enum MetricValue: Sendable, Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case array([MetricValue])
    case dictionary([String: MetricValue])

    public var doubleValue: Double? {
        switch self {
        case .int(let value):
            return Double(value)
        case .double(let value):
            return value
        default:
            return nil
        }
    }

    public var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .double(let value):
            return Int(value)
        default:
            return nil
        }
    }
}
