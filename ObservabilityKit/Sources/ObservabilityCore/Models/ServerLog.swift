//
//  ServerLog.swift
//  ObservabilityCore
//
//  📜 The Cosmic Log Oracle - Where Server Messages Become Observable Wisdom ✨
//
//  "In the digital realm, every log entry tells a story. This model captures
//  those stories, transforming raw text into structured insights."
//
//  - The Spellbinding Museum Director of Log Analysis

import Foundation

/// 📜 Server log entry - A single line of server wisdom
@available(macOS 14, iOS 17, *)
public struct ServerLogEntry: Sendable, Codable, Identifiable, Equatable {
    public let id: UUID
    public let timestamp: Date
    public let level: LogLevel
    public let message: String
    public let source: String // e.g., "nginx", "application", "system"
    public let statusCode: Int?
    public let requestPath: String?
    public let requestMethod: String?
    public let clientIP: String?
    public let userAgent: String?
    public let rawLine: String
    
    public init(
        id: UUID = UUID(),
        timestamp: Date,
        level: LogLevel,
        message: String,
        source: String,
        statusCode: Int? = nil,
        requestPath: String? = nil,
        requestMethod: String? = nil,
        clientIP: String? = nil,
        userAgent: String? = nil,
        rawLine: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.source = source
        self.statusCode = statusCode
        self.requestPath = requestPath
        self.requestMethod = requestMethod
        self.clientIP = clientIP
        self.userAgent = userAgent
        self.rawLine = rawLine
    }
    
    /// 🚨 Is this a 500 error?
    public var is500Error: Bool {
        statusCode == 500
    }
    
    /// ⚠️ Is this an error level log?
    public var isError: Bool {
        level == .error || level == .critical || is500Error
    }
}

/// 📊 Log level enumeration
@available(macOS 14, iOS 17, *)
public enum LogLevel: String, Sendable, Codable, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public var colorHex: String {
        switch self {
        case .debug:
            return "#95a5a6"
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
    
    public var icon: String {
        switch self {
        case .debug:
            return "🔍"
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
}

/// 📚 Server log collection with parsing capabilities
@available(macOS 14, iOS 17, *)
public struct ServerLogCollection: Sendable {
    public let entries: [ServerLogEntry]
    public let source: String
    public let fetchedAt: Date
    
    public init(
        entries: [ServerLogEntry] = [],
        source: String = "unknown",
        fetchedAt: Date = Date()
    ) {
        self.entries = entries.sorted { $0.timestamp > $1.timestamp } // Most recent first
        self.source = source
        self.fetchedAt = fetchedAt
    }
    
    /// 🚨 Get all 500 errors
    public var error500Entries: [ServerLogEntry] {
        entries.filter { $0.is500Error }
    }
    
    /// ⚠️ Get all error-level entries
    public var errorEntries: [ServerLogEntry] {
        entries.filter { $0.isError }
    }
    
    /// 📊 Get entries in time range
    public func entries(in timeRange: ClosedRange<Date>) -> [ServerLogEntry] {
        entries.filter { timeRange.contains($0.timestamp) }
    }
    
    /// 🔍 Get recent entries (last N minutes)
    public func recentEntries(minutes: Int = 60) -> [ServerLogEntry] {
        let cutoff = Date().addingTimeInterval(-Double(minutes * 60))
        return entries.filter { $0.timestamp >= cutoff }
    }
    
    /// 📈 Count errors by status code
    public var errorCountByStatusCode: [Int: Int] {
        Dictionary(grouping: entries.filter { $0.statusCode != nil }, by: { $0.statusCode! })
            .mapValues { $0.count }
    }
}

/// 🔍 Log parser - Transforms raw log text into structured entries
@available(macOS 14, iOS 17, *)
public struct LogParser {
    
    /// 🌐 Parse NGINX access log format
    /// Format: IP - - [timestamp] "METHOD path HTTP/version" status size "referer" "user-agent"
    public static func parseNginxAccessLog(_ logText: String, source: String = "nginx") -> [ServerLogEntry] {
        let lines = logText.components(separatedBy: .newlines)
        var entries: [ServerLogEntry] = []
        
        for line in lines {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            // Try to parse NGINX access log format
            if let entry = parseNginxAccessLine(line, source: source) {
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    /// 🌐 Parse NGINX error log format
    public static func parseNginxErrorLog(_ logText: String, source: String = "nginx") -> [ServerLogEntry] {
        let lines = logText.components(separatedBy: .newlines)
        var entries: [ServerLogEntry] = []
        
        for line in lines {
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            
            if let entry = parseNginxErrorLine(line, source: source) {
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    /// 🔍 Parse a single NGINX access log line
    private static func parseNginxAccessLine(_ line: String, source: String) -> ServerLogEntry? {
        // NGINX access log format: IP - - [timestamp] "METHOD path HTTP/version" status size "referer" "user-agent"
        // Example: 192.168.1.1 - - [25/Dec/2024:10:30:45 +0000] "GET /api/users HTTP/1.1" 500 1234 "-" "Mozilla/5.0"
        
        let components = line.components(separatedBy: " ")
        guard components.count >= 10 else { return nil }
        
        // Extract IP (first component)
        let clientIP = components[0]
        
        // Find timestamp in brackets [25/Dec/2024:10:30:45 +0000]
        var timestamp = Date()
        var timestampString = ""
        if let timestampRange = line.range(of: #"\[\d{2}/\w{3}/\d{4}:\d{2}:\d{2}:\d{2}"#, options: .regularExpression) {
            timestampString = String(line[timestampRange])
            timestampString = timestampString.replacingOccurrences(of: "[", with: "")
            if let parsedDate = parseNginxTimestamp(timestampString) {
                timestamp = parsedDate
            }
        }
        
        // Find request in quotes "METHOD path HTTP/version"
        var requestMethod: String?
        var requestPath: String?
        if let requestRange = line.range(of: #""\w+ [^"]+ HTTP/\d\.\d""#, options: .regularExpression) {
            let requestString = String(line[requestRange])
            let requestParts = requestString.replacingOccurrences(of: "\"", with: "").components(separatedBy: " ")
            if requestParts.count >= 2 {
                requestMethod = requestParts[0]
                requestPath = requestParts[1]
            }
        }
        
        // Find status code (usually after the request)
        var statusCode: Int?
        for component in components {
            if let code = Int(component), (100...599).contains(code) {
                statusCode = code
                break
            }
        }
        
        // Extract user agent (last quoted string)
        var userAgent: String?
        if let uaRange = line.range(of: #""[^"]*Mozilla[^"]*""#, options: .regularExpression) {
            userAgent = String(line[uaRange]).replacingOccurrences(of: "\"", with: "")
        }
        
        // Determine log level based on status code
        let level: LogLevel
        if let code = statusCode {
            switch code {
            case 200...299:
                level = .info
            case 300...399:
                level = .info
            case 400...499:
                level = .warning
            case 500...599:
                level = .error
            default:
                level = .info
            }
        } else {
            level = .info
        }
        
        let message = statusCode == 500 
            ? "HTTP 500 Error: \(requestMethod ?? "UNKNOWN") \(requestPath ?? "unknown path")"
            : "\(requestMethod ?? "REQUEST") \(requestPath ?? "unknown") - Status: \(statusCode ?? 0)"
        
        return ServerLogEntry(
            timestamp: timestamp,
            level: level,
            message: message,
            source: source,
            statusCode: statusCode,
            requestPath: requestPath,
            requestMethod: requestMethod,
            clientIP: clientIP,
            userAgent: userAgent,
            rawLine: line
        )
    }
    
    /// 🔍 Parse a single NGINX error log line
    private static func parseNginxErrorLine(_ line: String, source: String) -> ServerLogEntry? {
        // NGINX error log format: timestamp [level] pid#tid: *connection_id message
        // Example: 2024/12/25 10:30:45 [error] 1234#0: *3 connect() failed (111: Connection refused) while connecting to upstream
        // Or simpler: 2024/12/25 10:30:45 [error] connect() failed (111: Connection refused)
        
        guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        
        // Try to parse timestamp (first two space-separated components: date and time)
        var timestamp = Date()
        var timestampEndIndex = line.startIndex
        
        // Look for timestamp pattern: yyyy/MM/dd HH:mm:ss
        if let timestampRange = line.range(of: #"\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}"#, options: .regularExpression) {
            let dateString = String(line[timestampRange])
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let parsedDate = formatter.date(from: dateString) {
                timestamp = parsedDate
                timestampEndIndex = timestampRange.upperBound
            }
        }
        
        // Find log level in brackets [error], [warn], [crit], etc.
        var level: LogLevel = .info
        var levelEndIndex = timestampEndIndex
        
        // Look for [level] pattern after timestamp
        let remainingAfterTimestamp = String(line[timestampEndIndex...])
        if let levelRange = remainingAfterTimestamp.range(of: #"\[(debug|info|notice|warn|error|crit|alert|emerg)\]"#, options: [.regularExpression, .caseInsensitive]) {
            let levelString = String(remainingAfterTimestamp[levelRange])
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .lowercased()
            
            // Map NGINX log levels to our LogLevel enum
            switch levelString {
            case "debug":
                level = .debug
            case "info", "notice":
                level = .info
            case "warn":
                level = .warning
            case "error":
                level = .error
            case "crit", "alert", "emerg":
                level = .critical
            default:
                level = .info
            }
            
            // Calculate absolute position in original line
            let levelStartInRemaining = remainingAfterTimestamp.distance(from: remainingAfterTimestamp.startIndex, to: levelRange.lowerBound)
            let levelEndInRemaining = remainingAfterTimestamp.distance(from: remainingAfterTimestamp.startIndex, to: levelRange.upperBound)
            levelEndIndex = line.index(timestampEndIndex, offsetBy: levelEndInRemaining)
        }
        
        // Extract message: everything after [level] (skip PID/tid/connection info if present)
        // Format after level: " pid#tid: *connection_id message" or just " message"
        let messageStart = String(line[levelEndIndex...]).trimmingCharacters(in: .whitespaces)
        
        // Skip PID/tid pattern if present (e.g., "1234#0: *3 ")
        let message: String
        if let pidRange = messageStart.range(of: #"^\d+#\d+:\s*\*\d+\s+"#, options: .regularExpression) {
            // Skip PID/tid/connection info
            message = String(messageStart[pidRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else if let pidRange = messageStart.range(of: #"^\d+#\d+:\s+"#, options: .regularExpression) {
            // Skip PID/tid without connection
            message = String(messageStart[pidRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        } else {
            // No PID/tid, use as-is
            message = messageStart.trimmingCharacters(in: .whitespaces)
        }
        
        guard !message.isEmpty else { return nil }
        
        return ServerLogEntry(
            timestamp: timestamp,
            level: level,
            message: message,
            source: source,
            rawLine: line
        )
    }
    
    /// 📅 Parse NGINX timestamp format
    private static func parseNginxTimestamp(_ timestampString: String) -> Date? {
        // Format: 25/Dec/2024:10:30:45
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMM/yyyy:HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: timestampString)
    }
}
