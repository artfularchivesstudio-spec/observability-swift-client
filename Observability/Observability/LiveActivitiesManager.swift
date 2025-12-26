//
//  LiveActivitiesManager.swift
//  Observability
//
//  📊 The Cosmic Live Activity Conductor - Where Real-Time Metrics Live ✨
//
//  "The dynamic island of observability, bringing live metrics
//   to the forefront of user awareness"
//
//  - The Mystical Live Activity Virtuoso
//

#if os(iOS)
import Foundation
import ActivityKit
import WidgetKit
import ObservabilityCore

/// 📊 Live Activities manager for real-time service monitoring
@available(iOS 18.0, *)
@MainActor
class LiveActivitiesManager {
    static let shared = LiveActivitiesManager()
    
    private init() {}
    
    // MARK: - Activity Management
    
    /// 🚀 Start live activity for service monitoring
    func startServiceMonitoringActivity(service: ServiceInfo, health: HealthCheckResult) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = ServiceMonitoringAttributes(serviceName: service.name)
        let contentState = ServiceMonitoringAttributes.ContentState(
            status: health.status.displayName,
            cpuUsage: health.metrics["cpu"]?.doubleValue ?? 0,
            memoryUsage: health.metrics["memory"]?.doubleValue ?? 0,
            responseTime: health.responseTime
        )
        
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: Date().addingTimeInterval(60)
        )
        
        do {
            let activity = try Activity<ServiceMonitoringAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Started Live Activity: \(activity.id)")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    /// 🛑 Stop live activity
    func stopServiceMonitoringActivity(serviceName: String) async {
        for activity in Activity<ServiceMonitoringAttributes>.activities {
            if activity.attributes.serviceName == serviceName {
              await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
    
    /// 🔄 Update live activity
    func updateServiceMonitoringActivity(serviceName: String, health: HealthCheckResult) async {
        for activity in Activity<ServiceMonitoringAttributes>.activities {
            if activity.attributes.serviceName == serviceName {
                let contentState = ServiceMonitoringAttributes.ContentState(
                    status: health.status.displayName,
                    cpuUsage: health.metrics["cpu"]?.doubleValue ?? 0,
                    memoryUsage: health.metrics["memory"]?.doubleValue ?? 0,
                    responseTime: health.responseTime
                )
                
                let activityContent = ActivityContent(
                    state: contentState,
                    staleDate: Date().addingTimeInterval(60)
                )
                
                await activity.update(activityContent)
            }
        }
    }
}

// MARK: - Activity Attributes

@available(iOS 16.1, *)
struct ServiceMonitoringAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var cpuUsage: Double
        var memoryUsage: Double
        var responseTime: TimeInterval
    }
    
    var serviceName: String
}
#endif

