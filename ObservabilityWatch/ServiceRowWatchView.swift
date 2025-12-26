//
//  ServiceRowWatchView.swift
//  ObservabilityWatch
//
//  📱 The Cosmic Service Row - Compact Service Status Display ✨
//
//  "Every pixel counts on the watch - elegant, informative,
//   and glanceable service status at your wrist"
//
//  - The Mystical Watch Component Designer
//

import SwiftUI
import WatchKit
import ObservabilityCore

@available(watchOS 11, *)
struct ServiceRowWatchView: View {
    let service: ServiceInfo
    let health: HealthCheckResult?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                // Status Indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 6, height: 6)
                
                // Service Name
                Text(service.name)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                // Response Time
                if let health = health {
                    Text("\(Int(health.responseTime * 1000))ms")
                        .font(.caption2.monospaced())
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
    
    private var statusColor: Color {
        guard let health = health else { return .gray }
        switch health.status {
        case .operational:
            return .green
        case .degraded:
            return .yellow
        case .down:
            return .red
        case .maintenance:
            return .blue
        case .unknown:
            return .gray
        }
    }
}

