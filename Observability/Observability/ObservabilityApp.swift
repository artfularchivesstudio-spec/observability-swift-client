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
import Combine
import ObservabilityUI
import ObservabilityCore
#if os(macOS)
import AppKit
#endif

@main
struct ObservabilityApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #if os(macOS)
    @StateObject private var menuBarViewModel = MenuBarViewModel()
    #endif

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

        #if os(macOS)
        // 📊 Menu Bar Extra - Always-visible metrics in your status bar!
        MenuBarExtra {
            MenuBarContentView(viewModel: menuBarViewModel)
        } label: {
            MenuBarLabelView(viewModel: menuBarViewModel)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}

// MARK: - Menu Bar ViewModel 📊
#if os(macOS)
@available(macOS 14, *)
@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var cpuUsage: Double = 0
    @Published var memoryUsage: Double = 0
    @Published var healthyCount: Int = 0
    @Published var issueCount: Int = 0
    @Published var totalServices: Int = 5
    @Published var isConnected: Bool = false

    private var timer: Timer?

    init() {
        startPolling()
    }

    /// 🔄 Poll the monitoring API for fresh metrics
    func startPolling() {
        // Initial fetch
        Task { await fetchMetrics() }

        // Poll every 10 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchMetrics()
            }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func fetchMetrics() async {
        // Try to get real metrics from the API
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "MONITORING_API_KEY") as? String,
              !apiKey.isEmpty else {
            // Use sample data if no API key
            updateWithSampleData()
            return
        }

        let baseURL = "https://api-router.cloud/monitoring/custom/api"

        do {
            // Fetch PM2 status for metrics
            guard let url = URL(string: "\(baseURL)/pm2/status") else { return }
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            request.timeoutInterval = 5

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                updateWithSampleData()
                return
            }

            // Parse the response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                var totalCPU: Double = 0
                var totalMemory: Double = 0
                var healthy = 0
                var issues = 0

                for process in json {
                    if let monit = process["monit"] as? [String: Any] {
                        totalCPU += (monit["cpu"] as? Double) ?? 0
                        totalMemory += (monit["memory"] as? Double) ?? 0
                    }
                    if let status = process["pm2_env"] as? [String: Any],
                       let pmStatus = status["status"] as? String {
                        if pmStatus == "online" {
                            healthy += 1
                        } else {
                            issues += 1
                        }
                    }
                }

                self.cpuUsage = totalCPU / max(Double(json.count), 1)
                self.memoryUsage = min(totalMemory / (1024 * 1024 * 1024) * 100, 100) // Convert to percentage
                self.healthyCount = healthy
                self.issueCount = issues
                self.totalServices = json.count
                self.isConnected = true
            }
        } catch {
            updateWithSampleData()
        }
    }

    private func updateWithSampleData() {
        // Generate realistic sample data
        cpuUsage = Double.random(in: 2...15)
        memoryUsage = Double.random(in: 30...45)
        healthyCount = 5
        issueCount = 0
        totalServices = 5
        isConnected = false
    }
}

// MARK: - Menu Bar Label (shown in status bar) 🏷️
@available(macOS 14, *)
struct MenuBarLabelView: View {
    @ObservedObject var viewModel: MenuBarViewModel

    var body: some View {
        HStack(spacing: 4) {
            // Status dot
            Circle()
                .fill(viewModel.issueCount > 0 ? Color.orange : Color.green)
                .frame(width: 8, height: 8)

            // CPU percentage
            Text("C:\(Int(viewModel.cpuUsage))%")
                .font(.system(size: 10, weight: .medium, design: .monospaced))

            // Memory percentage
            Text("M:\(Int(viewModel.memoryUsage))%")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
        }
    }
}

// MARK: - Menu Bar Content (dropdown window) 📋
@available(macOS 14, *)
struct MenuBarContentView: View {
    @ObservedObject var viewModel: MenuBarViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🎭 Observatory")
                    .font(.headline)
                    .fontWeight(.bold)

                Spacer()

                // Connection status
                HStack(spacing: 4) {
                    Circle()
                        .fill(viewModel.isConnected ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(viewModel.isConnected ? "Live" : "Demo")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Services Status
            HStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("\(viewModel.healthyCount)/\(viewModel.totalServices)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Healthy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if viewModel.issueCount > 0 {
                    VStack(alignment: .leading) {
                        Text("\(viewModel.issueCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("Issues")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            Divider()

            // Metrics
            HStack(spacing: 20) {
                // CPU Gauge
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: viewModel.cpuUsage / 100)
                            .stroke(cpuColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(viewModel.cpuUsage))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .frame(width: 44, height: 44)

                    Text("CPU")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Memory Gauge
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: viewModel.memoryUsage / 100)
                            .stroke(memoryColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(viewModel.memoryUsage))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                    }
                    .frame(width: 44, height: 44)

                    Text("Memory")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            Divider()

            // Actions
            Button(action: {
                // Open main window
                NSApp.activate(ignoringOtherApps: true)
                if let window = NSApp.windows.first(where: { $0.title == "Dashboard" || $0.contentView != nil }) {
                    window.makeKeyAndOrderFront(nil)
                }
            }) {
                Label("Open Dashboard", systemImage: "rectangle.expand.vertical")
            }
            .buttonStyle(.plain)

            Button(action: {
                Task { await viewModel.fetchMetrics() }
            }) {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.plain)

            Divider()

            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label("Quit Observatory", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 220)
    }

    private var cpuColor: Color {
        if viewModel.cpuUsage > 80 { return .red }
        if viewModel.cpuUsage > 50 { return .orange }
        return .green
    }

    private var memoryColor: Color {
        if viewModel.memoryUsage > 80 { return .red }
        if viewModel.memoryUsage > 50 { return .orange }
        return .yellow
    }
}
#endif

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
