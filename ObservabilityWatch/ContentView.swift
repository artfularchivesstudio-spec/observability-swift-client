//
//  ContentView.swift
//  ObservabilityWatch
//
//  📊 The Cosmic Watch Dashboard - Glanceable Infrastructure Health ✨
//
//  "At a glance, know everything - the watch face becomes
//   your command center for infrastructure awareness"
//
//  - The Mystical Watch UI Architect
//

import SwiftUI
import WatchKit
import ObservabilityCore

@available(watchOS 11, *)
struct ContentView: View {
    @EnvironmentObject var viewModel: WatchDashboardViewModel
    @State private var selectedService: ServiceInfo?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // Header - Overall Status
                    headerView
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Services List
                    servicesListView
                    
                    // Quick Metrics
                    if !viewModel.metrics.isEmpty {
                        quickMetricsView
                    }
                }
                .padding(.horizontal, 4)
            }
            .navigationTitle("Services")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedService) { service in
                ServiceDetailWatchView(
                    service: service,
                    health: viewModel.healthResults[service.id]
                )
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 4) {
            HStack {
                // Connection Status
                Circle()
                    .fill(viewModel.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                
                Text(viewModel.isConnected ? "Connected" : "Disconnected")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Overall Health
                Text("\(viewModel.healthyCount)/\(viewModel.services.count)")
                    .font(.caption2.monospaced())
                    .foregroundColor(.secondary)
            }
            
            // Health Percentage
            HStack {
                Text("Health")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(viewModel.healthPercentage))%")
                    .font(.title3.monospaced())
                    .fontWeight(.bold)
                    .foregroundColor(healthColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Services List View
    private var servicesListView: some View {
        VStack(spacing: 6) {
            ForEach(viewModel.services.prefix(5)) { service in
                ServiceRowWatchView(
                    service: service,
                    health: viewModel.healthResults[service.id]
                ) {
                    selectedService = service
                }
            }
            
            if viewModel.services.count > 5 {
                Text("+ \(viewModel.services.count - 5) more")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Quick Metrics View
    private var quickMetricsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Metrics")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                MetricBadgeWatchView(
                    label: "CPU",
                    value: viewModel.averageCPU,
                    unit: "%"
                )
                
                MetricBadgeWatchView(
                    label: "Mem",
                    value: viewModel.averageMemory,
                    unit: "%"
                )
            }
        }
        .padding(.top, 4)
    }
    
    // MARK: - Computed Properties
    private var healthColor: Color {
        let percentage = viewModel.healthPercentage
        if percentage >= 90 {
            return .green
        } else if percentage >= 70 {
            return .yellow
        } else {
            return .red
        }
    }
}

