//
//  ObservabilityWidget.swift
//  ObservabilityWidgets
//
//  📱 The Cosmic Widget Extension - Where Metrics Live on Your Home Screen ✨
//
//  "The persistent presence of observability, always visible,
//   always aware, always monitoring"
//
//  - The Mystical Widget Architect
//

import WidgetKit
import SwiftUI
import ObservabilityCore

/// 📱 Main widget configuration
@main
struct ObservabilityWidget: Widget {
    let kind: String = "ObservabilityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ServiceStatusProvider()) { entry in
            ObservabilityWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Service Status")
        .description("Monitor your infrastructure services at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/// 📊 Widget entry with service status data
struct ServiceStatusEntry: TimelineEntry {
    let date: Date
    let services: [ServiceStatusInfo]
    let totalAlerts: Int
}

struct ServiceStatusInfo {
    let name: String
    let status: ServiceStatus
    let cpuUsage: Double
    let memoryUsage: Double
}

/// 🔄 Timeline provider for widget updates
struct ServiceStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> ServiceStatusEntry {
        ServiceStatusEntry(
            date: Date(),
            services: [
                ServiceStatusInfo(name: "Strapi CMS", status: .operational, cpuUsage: 25, memoryUsage: 150),
                ServiceStatusInfo(name: "Website", status: .operational, cpuUsage: 15, memoryUsage: 80)
            ],
            totalAlerts: 0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ServiceStatusEntry) -> Void) {
        let entry = ServiceStatusEntry(
            date: Date(),
            services: [
                ServiceStatusInfo(name: "Strapi CMS", status: .operational, cpuUsage: 25, memoryUsage: 150),
                ServiceStatusInfo(name: "Website", status: .operational, cpuUsage: 15, memoryUsage: 80)
            ],
            totalAlerts: 0
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ServiceStatusEntry>) -> Void) {
        // Update every 15 minutes
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        
        let entry = ServiceStatusEntry(
            date: currentDate,
            services: loadServiceStatuses(),
            totalAlerts: loadActiveAlertsCount()
        )
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func loadServiceStatuses() -> [ServiceStatusInfo] {
        // Load from shared app group or UserDefaults
        // This would connect to your monitoring API
        return []
    }
    
    private func loadActiveAlertsCount() -> Int {
        // Load from shared app group
        return 0
    }
}

/// 🎨 Widget entry view
struct ObservabilityWidgetEntryView: View {
    var entry: ServiceStatusProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Infrastructure")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if entry.totalAlerts > 0 {
                    Text("\(entry.totalAlerts)")
                        .font(.caption)
                        .padding(4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            
            // Services
            ForEach(entry.services.prefix(3), id: \.name) { service in
                ServiceRow(service: service)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ServiceRow: View {
    let service: ServiceStatusInfo
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(service.name)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(Int(service.cpuUsage))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private var statusColor: Color {
        switch service.status {
        case .operational:
            return .green
        case .degraded:
            return .orange
        case .down:
            return .red
        default:
            return .gray
        }
    }
}

#Preview(as: .systemSmall) {
    ObservabilityWidget()
} timeline: {
    ServiceStatusEntry(
        date: Date(),
        services: [
            ServiceStatusInfo(name: "Strapi CMS", status: .operational, cpuUsage: 25, memoryUsage: 150)
        ],
        totalAlerts: 0
    )
}

