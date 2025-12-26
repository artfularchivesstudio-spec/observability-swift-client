//
//  ExtensionDelegate.swift
//  ObservabilityWatch Extension
//
//  ⌚️ The Cosmic Watch Extension Delegate - Bridge Between Worlds ✨
//
//  "The mystical conductor that orchestrates the watch extension lifecycle,
//   managing background tasks, notifications, and the eternal dance of
//   observability across the dimensions of time and space"
//
//  - The Interdimensional Watch Guardian
//

import WatchKit
import Foundation
import ObservabilityCore

/// ⌚️ Watch extension delegate handling app lifecycle and background tasks
@available(watchOS 11, *)
class ExtensionDelegate: NSObject, WKExtensionDelegate {
    
    // MARK: - Lifecycle
    
    func applicationDidFinishLaunching() {
        // Initialize any global watch extension state
        print("🌟 ObservabilityWatch extension launched with cosmic awareness")
        
        // Setup background refresh
        scheduleBackgroundRefresh()
    }
    
    func applicationDidBecomeActive() {
        // App became active - good time to refresh data
        print("👁️ Watch extension awakened from digital slumber")
    }
    
    func applicationWillResignActive() {
        // App will become inactive - save state if needed
        print("😴 Watch extension entering cosmic meditation")
    }
    
    func applicationDidEnterBackground() {
        // App entered background - schedule background refresh
        scheduleBackgroundRefresh()
    }
    
    func applicationWillEnterForeground() {
        // App will enter foreground - cancel background tasks
        print("🌅 Watch extension emerging from background dimensions")
    }
    
    // MARK: - Background Refresh
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundRefreshTask as WKApplicationRefreshBackgroundTask:
                // Handle background refresh
                handleBackgroundRefresh(task: backgroundRefreshTask)
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Handle snapshot refresh
                snapshotTask.setTaskCompletedWithSnapshot(false)
                
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Handle connectivity refresh
                connectivityTask.setTaskCompletedWithSnapshot(false)
                
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Handle URL session background task
                urlSessionTask.setTaskCompletedWithSnapshot(false)
                
            default:
                // Handle any other task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleBackgroundRefresh(task: WKApplicationRefreshBackgroundTask) {
        // Perform background health checks
        Task {
            do {
                // Quick health check in background
                await performBackgroundHealthChecks()
                
                // Schedule next background refresh
                scheduleBackgroundRefresh()
                
                // Mark task as completed
                task.setTaskCompletedWithSnapshot(false)
                
            } catch {
                print("🚨 Background refresh failed: \(error)")
                task.setTaskCompletedWithSnapshot(true)
            }
        }
    }
    
    private func scheduleBackgroundRefresh() {
        // Schedule background refresh every 15 minutes
        let nextRefreshDate = Date().addingTimeInterval(15 * 60)
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: nextRefreshDate, userInfo: nil) { error in
            if let error = error {
                print("🚨 Failed to schedule background refresh: \(error)")
            } else {
                print("⏰ Next background refresh scheduled for \(nextRefreshDate)")
            }
        }
    }
    
    private func performBackgroundHealthChecks() async {
        // Lightweight background monitoring
        // This would typically check critical services only
        print("🔍 Performing background observability checks...")
        
        // Simulate quick health check
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds max
        
        print("✅ Background health checks completed")
    }
}