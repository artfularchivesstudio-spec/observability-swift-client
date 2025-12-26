//
//  PushNotificationsManager.swift
//  Observability
//
//  🔔 The Cosmic Notification Conduit - Where Alerts Become Push Messages ✨
//
//  "The bridge between critical infrastructure events and user awareness,
//   ensuring no alert goes unnoticed"
//
//  - The Mystical Notification Herald
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
import ObservabilityCore

/// 🔔 Push notifications manager for critical alerts
@available(macOS 14, iOS 17, *)
@MainActor
class PushNotificationsManager: NSObject, ObservableObject {
    static let shared = PushNotificationsManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isRegistered = false
    
    private override init() {
        super.init()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    /// 📝 Request notification permissions
    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        
        await MainActor.run {
            isRegistered = granted
        }
        
        await checkAuthorizationStatus()
    }
    
    /// 🔍 Check current authorization status
    func checkAuthorizationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            authorizationStatus = settings.authorizationStatus
            isRegistered = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Sending Notifications
    
    /// 🚨 Send notification for critical alert
    func sendCriticalAlert(_ alert: ObservabilityCore.Alert) async {
        let content = UNMutableNotificationContent()
        content.title = "🚨 Critical: \(alert.title)"
        content.body = alert.message
        content.sound = .defaultCritical
        content.categoryIdentifier = "CRITICAL_ALERT"
        content.userInfo = [
            "alertId": alert.id.uuidString,
            "severity": alert.severity.rawValue,
            "serviceName": alert.source.serviceName
        ]
        content.interruptionLevel = .critical
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil // Immediate
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send critical alert: \(error)")
        }
    }
    
    /// ⚠️ Send notification for error alert
    func sendErrorAlert(_ alert: ObservabilityCore.Alert) async {
        let content = UNMutableNotificationContent()
        content.title = "❌ Error: \(alert.title)"
        content.body = alert.message
        content.sound = .default
        content.categoryIdentifier = "ERROR_ALERT"
        content.userInfo = [
            "alertId": alert.id.uuidString,
            "severity": alert.severity.rawValue,
            "serviceName": alert.source.serviceName
        ]
        content.interruptionLevel = .timeSensitive
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send error alert: \(error)")
        }
    }
    
    /// ⚠️ Send notification for warning alert
    func sendWarningAlert(_ alert: ObservabilityCore.Alert) async {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Warning: \(alert.title)"
        content.body = alert.message
        content.sound = .default
        content.categoryIdentifier = "WARNING_ALERT"
        content.userInfo = [
            "alertId": alert.id.uuidString,
            "severity": alert.severity.rawValue,
            "serviceName": alert.source.serviceName
        ]
        
        let request = UNNotificationRequest(
            identifier: alert.id.uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send warning alert: \(error)")
        }
    }
    
    /// 📊 Send notification for service status change
    func sendServiceStatusChange(serviceName: String, status: ServiceStatus) async {
        let content = UNMutableNotificationContent()
        
        switch status {
        case .down(let lastSeen, let reason):
            content.title = "🔴 \(serviceName) is Down"
            content.body = reason
            content.sound = .defaultCritical
            content.interruptionLevel = .critical
        case .degraded:
            content.title = "⚠️ \(serviceName) Performance Degraded"
            content.body = "Service is experiencing performance issues"
            content.interruptionLevel = .timeSensitive
        case .operational:
            content.title = "✅ \(serviceName) is Operational"
            content.body = "Service has recovered"
            content.sound = .default
        default:
            return
        }
        
        content.categoryIdentifier = "SERVICE_STATUS"
        content.userInfo = [
            "serviceName": serviceName,
            "status": status.displayName
        ]
        
        let request = UNNotificationRequest(
            identifier: "\(serviceName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to send service status notification: \(error)")
        }
    }
    
    // MARK: - Notification Categories
    
    /// 🎯 Register notification categories with actions
    func registerNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        
        // Critical Alert Category
        let acknowledgeAction = UNNotificationAction(
            identifier: "ACKNOWLEDGE",
            title: "Acknowledge",
            options: []
        )
        
        let viewAction = UNNotificationAction(
            identifier: "VIEW",
            title: "View Details",
            options: .foreground
        )
        
        let criticalCategory = UNNotificationCategory(
            identifier: "CRITICAL_ALERT",
            actions: [acknowledgeAction, viewAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([criticalCategory])
    }
}

// MARK: - UNUserNotificationCenterDelegate

@available(macOS 14, iOS 17, *)
extension PushNotificationsManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let alertIdString = userInfo["alertId"] as? String,
           let alertId = UUID(uuidString: alertIdString) {
            // Handle alert action
            switch response.actionIdentifier {
            case "ACKNOWLEDGE":
                // Acknowledge alert
                break
            case "VIEW":
                // Navigate to alert detail
                break
            default:
                break
            }
        }
        
        completionHandler()
    }
}

