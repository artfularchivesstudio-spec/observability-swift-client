//
//  NotificationManager.swift
//  ObservabilityUI
//
//  🔔 The Cosmic Notification Oracle - Where Alerts Become System-Wide Warnings ✨
//
//  "When digital chaos strikes, this manager ensures you're immediately aware,
//  transforming silent errors into audible alerts that demand attention."
//
//  - The Spellbinding Museum Director of Alert Systems

import Foundation
import UserNotifications
import ObservabilityCore

/// 🔔 Notification manager for sending system notifications
@available(macOS 14, iOS 17, *)
@MainActor
public class NotificationManager {
    
    public init() {}
    
    /// 🔐 Request notification authorization from the user
    public func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("🔔 Notification permissions granted ✨")
            } else {
                print("🌙 Notification permissions denied - user will not receive alerts")
            }
        } catch {
            print("🌩️ Failed to request notification permissions: \(error.localizedDescription)")
        }
    }
    
    /// 📢 Send notification for an alert
    public func sendAlertNotification(alert: Alert) async {
        let center = UNUserNotificationCenter.current()
        
        // Check authorization status
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("🌙 Notifications not authorized - skipping alert notification")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = alert.title
        content.body = alert.message
        content.sound = notificationSound(for: alert.severity)
        content.categoryIdentifier = "ALERT"
        
        // Add user info for deep linking
        content.userInfo = [
            "alert_id": alert.id.uuidString,
            "severity": alert.severity.rawValue,
            "service": alert.source.serviceName
        ]
        
        // Set badge count (optional)
        content.badge = NSNumber(value: 1)
        
        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await center.add(request)
            print("🔔 Sent notification for alert: \(alert.title)")
        } catch {
            print("🌩️ Failed to send notification: \(error.localizedDescription)")
        }
    }
    
    /// 📢 Send notification when a service goes down
    public func sendServiceDownNotification(serviceName: String, reason: String) async {
        let center = UNUserNotificationCenter.current()
        
        // Check authorization status
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "🚨 Service Down: \(serviceName)"
        content.body = reason
        content.sound = .defaultCritical
        content.categoryIdentifier = "SERVICE_DOWN"
        
        // Add user info
        content.userInfo = [
            "service_name": serviceName,
            "type": "service_down"
        ]
        
        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "service_down_\(serviceName)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await center.add(request)
            print("🔔 Sent service down notification for: \(serviceName)")
        } catch {
            print("🌩️ Failed to send service down notification: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 🚀 App Lifecycle Notifications

    /// 🚀 Send notification when app launches and monitoring begins
    public func sendAppLaunchedNotification() async {
        await sendLifecycleNotification(
            title: "🎭 Observability Active",
            body: "Monitoring dashboard is now running. Real-time updates enabled.",
            identifier: "app_launched",
            sound: .default
        )
    }

    /// 🌐 Send notification when WebSocket connects successfully
    public func sendWebSocketConnectedNotification(endpoint: String? = nil) async {
        let body = endpoint != nil
            ? "Real-time connection established to \(endpoint!)"
            : "Real-time connection established to monitoring server"

        await sendLifecycleNotification(
            title: "🔌 WebSocket Connected",
            body: body,
            identifier: "websocket_connected",
            sound: .default
        )
    }

    /// 🔌 Send notification when WebSocket disconnects
    public func sendWebSocketDisconnectedNotification(reason: String? = nil) async {
        let body = reason ?? "Real-time connection lost. Attempting to reconnect..."

        await sendLifecycleNotification(
            title: "⚠️ WebSocket Disconnected",
            body: body,
            identifier: "websocket_disconnected",
            sound: .default
        )
    }

    /// 🔄 Send notification when WebSocket is reconnecting
    public func sendWebSocketReconnectingNotification(attempt: Int, maxAttempts: Int) async {
        await sendLifecycleNotification(
            title: "🔄 Reconnecting...",
            body: "Attempt \(attempt) of \(maxAttempts) to restore real-time connection",
            identifier: "websocket_reconnecting",
            sound: .default
        )
    }

    /// ✅ Send notification when all services are healthy
    public func sendAllServicesHealthyNotification(serviceCount: Int) async {
        await sendLifecycleNotification(
            title: "✅ All Services Healthy",
            body: "All \(serviceCount) monitored services are operational",
            identifier: "all_services_healthy",
            sound: .default
        )
    }

    /// 📊 Send notification with health summary
    public func sendHealthSummaryNotification(healthy: Int, degraded: Int, down: Int) async {
        let total = healthy + degraded + down
        var body = "\(healthy)/\(total) services operational"

        if degraded > 0 {
            body += ", \(degraded) degraded"
        }
        if down > 0 {
            body += ", \(down) down"
        }

        let title = down > 0 ? "🚨 Service Issues Detected" : (degraded > 0 ? "⚠️ Services Degraded" : "✅ Services Healthy")
        let sound: UNNotificationSound = down > 0 ? .defaultCritical : .default

        await sendLifecycleNotification(
            title: title,
            body: body,
            identifier: "health_summary",
            sound: sound
        )
    }

    /// 📜 Send notification when new logs are received
    public func sendNewLogsNotification(count: Int, hasErrors: Bool) async {
        guard count > 0 else { return }

        let title = hasErrors ? "📜 New Logs (with errors)" : "📜 New Logs Received"
        let body = "\(count) new log entries fetched from server"

        await sendLifecycleNotification(
            title: title,
            body: body,
            identifier: "new_logs_\(Date().timeIntervalSince1970)",
            sound: hasErrors ? .default : nil
        )
    }

    // MARK: - 🔧 Private Helpers

    /// 📨 Generic lifecycle notification sender - the cosmic messenger ✨
    private func sendLifecycleNotification(
        title: String,
        body: String,
        identifier: String,
        sound: UNNotificationSound?
    ) async {
        let center = UNUserNotificationCenter.current()

        // Check authorization status
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("🌙 Notifications not authorized - skipping: \(title)")
            return
        }

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        if let sound = sound {
            content.sound = sound
        }
        content.categoryIdentifier = "LIFECYCLE"

        // Add timestamp to user info
        content.userInfo = [
            "type": "lifecycle",
            "timestamp": Date().timeIntervalSince1970
        ]

        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)

        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        // Schedule notification
        do {
            try await center.add(request)
            print("🔔 \(title)")
        } catch {
            print("🌩️ Failed to send notification: \(error.localizedDescription)")
        }
    }

    /// 🎵 Get notification sound based on alert severity
    private func notificationSound(for severity: AlertSeverity) -> UNNotificationSound {
        switch severity {
        case .info:
            return .default
        case .warning:
            return .default
        case .error:
            #if os(macOS)
            return .default
            #else
            return .defaultCritical
            #endif
        case .critical:
            #if os(macOS)
            return .default
            #else
            return .defaultCritical
            #endif
        }
    }
}
