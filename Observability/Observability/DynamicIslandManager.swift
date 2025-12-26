//
//  DynamicIslandManager.swift
//  Observability
//
//  🏝️ The Cosmic Dynamic Island Conductor - Where Metrics Live in the Notch ✨
//
//  "The pinnacle of iOS integration, bringing observability
//   to the most prominent real estate on iPhone 14 Pro+"
//
//  - The Mystical Island Architect
//

#if os(iOS)
import Foundation
import ActivityKit
import WidgetKit
import ObservabilityCore

/// 🏝️ Dynamic Island manager for iPhone 14 Pro+ devices
@available(macOS 14, iOS 17, *)
@MainActor
class DynamicIslandManager {
    static let shared = DynamicIslandManager()
    
    private init() {}
    
    /// 🚀 Start Dynamic Island activity for critical service monitoring
    func startCriticalServiceMonitoring(service: ServiceInfo, health: HealthCheckResult) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        
        // Only show in Dynamic Island for critical issues
        guard case .down = health.status else {
            return
        }
        
        let attributes = DynamicIslandServiceAttributes(serviceName: service.name)
        let contentState = DynamicIslandServiceAttributes.ContentState(
            status: health.status.displayName,
            isCritical: true
        )
        
        let activityContent = ActivityContent(
            state: contentState,
            staleDate: Date().addingTimeInterval(300)
        )
        
        do {
            let activity = try Activity<DynamicIslandServiceAttributes>.request(
                attributes: attributes,
                content: activityContent,
                pushType: nil
            )
            print("Started Dynamic Island activity: \(activity.id)")
        } catch {
            print("Failed to start Dynamic Island activity: \(error)")
        }
    }
    
    /// 🛑 Stop Dynamic Island activity
    func stopServiceMonitoring(serviceName: String) async {
        for activity in Activity<DynamicIslandServiceAttributes>.activities {
            if activity.attributes.serviceName == serviceName {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
}

// MARK: - Dynamic Island Attributes

@available(macOS 14, iOS 17, *)
struct DynamicIslandServiceAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var isCritical: Bool
    }
    
    var serviceName: String
}
#endif

