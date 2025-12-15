//
//  Alert.swift
//  ObservabilityCore
//
//  🚨 The Cosmic Alert System - Where Digital Warnings Become Enlightened Messages ✨
//

import Foundation

/// 🚨 Alert severity levels
@available(macOS 14, iOS 17, *)
public enum AlertSeverity: String, Sendable, Codable, CaseIterable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"

    public var displayName: String {
        switch self {
        case .info:
            return "Info"
        case .warning:
            return "Warning"
        case .error:
            return "Error"
        case .critical:
            return "Critical"
        }
    }

    public var icon: String {
        switch self {
        case .info:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .error:
            return "❌"
        case .critical:
            return "🚨"
        }
    }

    public var colorHex: String {
        switch self {
        case .info:
            return "#3498db"
        case .warning:
            return "#f39c12"
        case .error:
            return "#e74c3c"
        case .critical:
            return "#c0392b"
        }
    }

    public var soundName: String? {
        switch self {
        case .info:
            return nil
        case .warning:
            return "warning.aiff"
        case .error:
            return "error.aiff"
        case .critical:
            return "critical.aiff"
        }
    }
}

/// 🚨 Alert model with rich context
@available(macOS 14, iOS 17, *)
public struct Alert: Sendable, Codable, Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let message: String
    public let severity: AlertSeverity
    public let source: AlertSource
    public let timestamp: Date
    public let acknowledged: Bool
    public let resolved: Bool
    public let tags: Set<String>
    public var metadata: [String: String]

    public init(
        id: UUID = UUID(),
        title: String,
        message: String,
        severity: AlertSeverity,
        source: AlertSource,
        timestamp: Date = Date(),
        acknowledged: Bool = false,
        resolved: Bool = false,
        tags: Set<String> = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.severity = severity
        self.source = source
        self.timestamp = timestamp
        self.acknowledged = acknowledged
        self.resolved = resolved
        self.tags = tags
        self.metadata = metadata
    }

    public struct AlertSource: Sendable, Codable, Equatable {
        public let serviceId: UUID?
        public let serviceName: String
        public let checkType: String
        public let location: String?

        public init(
            serviceId: UUID? = nil,
            serviceName: String,
            checkType: String,
            location: String? = nil
        ) {
            self.serviceId = serviceId
            self.serviceName = serviceName
            self.checkType = checkType
            self.location = location
        }
    }

    public var age: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }

    public var ageDescription: String {
        let interval = Date().timeIntervalSince(timestamp)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)\(minutes == 1 ? "m" : "m") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)\(hours == 1 ? "h" : "h") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)\(days == 1 ? "d" : "d") ago"
        }
    }
}

/// 📊 Alert statistics
@available(macOS 14, iOS 17, *)
public struct AlertStats: Sendable, Codable {
    public let totalCount: Int
    public let bySeverity: [AlertSeverity: Int]
    public let byService: [String: Int]
    public let recentCount: Int
    public let acknowledgedCount: Int
    public let unresolvedCount: Int

    public init(
        totalCount: Int = 0,
        bySeverity: [AlertSeverity: Int] = [:],
        byService: [String: Int] = [:],
        recentCount: Int = 0,
        acknowledgedCount: Int = 0,
        unresolvedCount: Int = 0
    ) {
        self.totalCount = totalCount
        self.bySeverity = bySeverity
        self.byService = byService
        self.recentCount = recentCount
        self.acknowledgedCount = acknowledgedCount
        self.unresolvedCount = unresolvedCount
    }
}

/// 🔔 Notification preferences
@available(macOS 14, iOS 17, *)
public struct NotificationPreferences: Sendable, Codable {
    public var enabled: Bool
    public var criticalOnly: Bool
    public var doNotDisturbUntil: Date?
    public var soundEnabled: Bool
    public var badgesEnabled: Bool
    public var services: Set<String>

    public init(
        enabled: Bool = true,
        criticalOnly: Bool = false,
        doNotDisturbUntil: Date? = nil,
        soundEnabled: Bool = true,
        badgesEnabled: Bool = true,
        services: Set<String> = []
    ) {
        self.enabled = enabled
        self.criticalOnly = criticalOnly
        self.doNotDisturbUntil = doNotDisturbUntil
        self.soundEnabled = soundEnabled
        self.badgesEnabled = badgesEnabled
        self.services = services
    }

    public var shouldNotify: Bool {
        guard enabled else { return false }
        if let dndUntil = doNotDisturbUntil, Date() < dndUntil {
            return false
        }
        return true
    }
}
