//
//  ServiceDetailWatchView.swift
//  ObservabilityWatch
//
//  🔍 The Cosmic Service Detail - Deep Dive on Your Wrist ✨
//
//  "All the details you need, optimized for the smallest screen -
//   because sometimes you need more than a glance"
//
//  - The Mystical Watch Detail Architect
//

import SwiftUI
import WatchKit
import ObservabilityCore

@available(watchOS 11, *)
struct ServiceDetailWatchView: View {
    let service: ServiceInfo
    let health: HealthCheckResult?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                // Service Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.name)
                        .font(.headline)
                    
                    Text(service.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Status Section
                if let health = health {
                    statusSection(health: health)
                    
                    Divider()
                    
                    // Metrics Section
                    metricsSection(health: health)
                } else {
                    Text("Checking...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func statusSection(health: HealthCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Status")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Circle()
                    .fill(statusColor(for: health.status))
                    .frame(width: 8, height: 8)
                
                Text(health.status.displayName)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            
            if case .down(let lastSeen, let reason) = health.status {
                Text(reason)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
    
    private func metricsSection(health: HealthCheckResult) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Metrics")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let cpu = health.metrics["cpu"]?.doubleValue {
                MetricRowWatchView(label: "CPU", value: cpu, unit: "%")
            }
            
            if let memory = health.metrics["memory"]?.doubleValue {
                MetricRowWatchView(label: "Memory", value: memory, unit: "%")
            }
            
            if let restarts = health.metrics["restarts"]?.intValue {
                MetricRowWatchView(label: "Restarts", value: Double(restarts), unit: "")
            }
        }
    }
    
    private func statusColor(for status: ServiceStatus) -> Color {
        switch status {
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

@available(watchOS 11, *)
struct MetricRowWatchView: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(value))\(unit)")
                .font(.caption.monospaced())
                .fontWeight(.semibold)
        }
    }
}

