//
//  ObservabilityComplications.swift
//  ObservabilityWatch
//
//  🎯 The Cosmic Complications - Watch Face Integration ✨
//
//  "Always visible, always aware - complications bring
//   infrastructure health to your watch face"
//
//  - The Mystical Complication Architect
//

import SwiftUI
import WidgetKit
import WatchKit
import ObservabilityCore

// MARK: - Complication Provider
@available(watchOS 11, *)
struct ObservabilityComplicationProvider: TimelineProvider {
    typealias Entry = ObservabilityComplicationEntry
    
    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            healthPercentage: 95,
            healthyCount: 5,
            totalCount: 5,
            status: .operational
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(
            date: Date(),
            healthPercentage: 95,
            healthyCount: 5,
            totalCount: 5,
            status: .operational
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Update every 15 minutes for complications
        let currentDate = Date()
        let entry = Entry(
            date: currentDate,
            healthPercentage: 95, // Would fetch from shared data
            healthyCount: 5,
            totalCount: 5,
            status: .operational
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Complication Entry
struct ObservabilityComplicationEntry: TimelineEntry {
    let date: Date
    let healthPercentage: Double
    let healthyCount: Int
    let totalCount: Int
    let status: ServiceStatus
}

// MARK: - Graphic Circular Complication
@available(watchOS 11, *)
struct ObservabilityGraphicCircularComplication: View {
    let entry: ObservabilityComplicationEntry
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(healthColor.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: entry.healthPercentage / 100)
                .stroke(healthColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 0) {
                Text("\(Int(entry.healthPercentage))")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(healthColor)
                
                Text("%")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var healthColor: Color {
        if entry.healthPercentage >= 90 {
            return .green
        } else if entry.healthPercentage >= 70 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Modular Small Complication
@available(watchOS 11, *)
struct ObservabilityModularSmallComplication: View {
    let entry: ObservabilityComplicationEntry
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "server.rack")
                .font(.system(size: 16))
                .foregroundColor(healthColor)
            
            Text("\(entry.healthyCount)/\(entry.totalCount)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    private var healthColor: Color {
        if entry.healthPercentage >= 90 {
            return .green
        } else if entry.healthPercentage >= 70 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Complication Bundle
@available(watchOS 11, *)
struct ObservabilityComplications: WidgetBundle {
    var body: some Widget {
        ObservabilityGraphicCircularWidget()
        ObservabilityModularSmallWidget()
    }
}

@available(watchOS 11, *)
struct ObservabilityGraphicCircularWidget: Widget {
    let kind: String = "ObservabilityGraphicCircular"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ObservabilityComplicationProvider()) { entry in
            ObservabilityGraphicCircularComplication(entry: entry)
        }
        .configurationDisplayName("Health %")
        .description("Shows overall infrastructure health percentage")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(watchOS 11, *)
struct ObservabilityModularSmallWidget: Widget {
    let kind: String = "ObservabilityModularSmall"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ObservabilityComplicationProvider()) { entry in
            ObservabilityModularSmallComplication(entry: entry)
        }
        .configurationDisplayName("Services")
        .description("Shows healthy/total service count")
        .supportedFamilies([.accessoryRectangular])
    }
}

