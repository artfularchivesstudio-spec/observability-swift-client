//
//  MetricBadgeWatchView.swift
//  ObservabilityWatch
//
//  📊 The Cosmic Metric Badge - Compact Metric Display ✨
//
//  "Small but mighty - essential metrics at a glance,
//   designed for the watch's compact canvas"
//
//  - The Mystical Watch Badge Designer
//

import SwiftUI
import WatchKit
import ObservabilityCore

@available(watchOS 11, *)
struct MetricBadgeWatchView: View {
    let label: String
    let value: Double
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(value))")
                    .font(.caption.monospaced())
                    .fontWeight(.bold)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.1))
        )
    }
}

