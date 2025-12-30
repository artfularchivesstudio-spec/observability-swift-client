//
//  ObservabilityApp.swift
//  Observability
//
//  🔔 The Cosmic App Entry Point - Where Notifications Awaken ✨
//
//  "At the dawn of the app, we request permission to alert you of digital disturbances,
//  ensuring you're never caught off guard by server errors."
//
//  - The Spellbinding Museum Director of App Lifecycle

import SwiftUI
import UserNotifications
import ObservabilityUI
#if os(macOS)
import AppKit
#endif

@main
struct ObservabilityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Request notification permissions on app launch (using ObservabilityUI.NotificationManager)
        Task {
            let notificationManager = NotificationManager()
            await notificationManager.requestAuthorization()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
    }
}

/// 🎭 App delegate for handling notifications
@available(macOS 14, iOS 17, *)
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        #if os(macOS)
        completionHandler([.banner, .sound, .badge])
        #else
        completionHandler([.banner, .sound, .badge, .list])
        #endif
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap - could navigate to alert detail
        let userInfo = response.notification.request.content.userInfo
        if let alertID = userInfo["alert_id"] as? String {
            print("🔔 User tapped notification for alert: \(alertID)")
            // TODO: Navigate to alert detail view
        }
        completionHandler()
    }
}
