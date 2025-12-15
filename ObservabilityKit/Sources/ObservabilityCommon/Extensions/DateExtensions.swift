//
//  DateExtensions.swift
//  ObservabilityCommon
//
//  ⏰ The Temporal Extensions - Where Time Becomes Observable ✨
//

import Foundation

@available(macOS 14, iOS 17, *)
public extension Date {
    /// 🌟 Format date for display in observability UI
    func formattedForDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    /// 📊 Format as precise timestamp
    func formattedAsTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }

    /// 🎭 Format as full date and time
    func formattedAsDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }

    /// ⏱️ Calculate time ago string
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) \(days == 1 ? "day" : "days") ago"
        }
    }
}

@available(macOS 14, iOS 17, *)
public extension TimeInterval {
    /// 🌟 Format time interval for display
    func formattedDuration() -> String {
        if self < 1 {
            return "\(Int(self * 1000))ms"
        } else if self < 60 {
            return String(format: "%.2fs", self)
        } else if self < 3600 {
            let minutes = Int(self) / 60
            let seconds = Int(self) % 60
            return "\(minutes)m \(seconds)s"
        } else {
            let hours = Int(self) / 3600
            let minutes = (Int(self) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }

    /// 📊 Format as precise milliseconds
    func formattedAsMilliseconds() -> String {
        return "\(Int(self * 1000))ms"
    }

    /// 🎭 Format as uptime string
    func formattedAsUptime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 2
        return formatter.string(from: self) ?? "Unknown"
    }
}
