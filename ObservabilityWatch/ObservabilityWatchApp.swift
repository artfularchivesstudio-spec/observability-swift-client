//
//  ObservabilityWatchApp.swift
//  ObservabilityWatch
//
//  ⌚️ The Cosmic Watch Conductor - Where Infrastructure Lives on Your Wrist ✨
//
//  "The smallest screen, the biggest impact - bringing observability
//   to the most personal device in the Apple ecosystem"
//
//  - The Mystical Watch Virtuoso
//

import SwiftUI
import WatchKit
import ObservabilityCore
import ObservabilityNetworking

@available(watchOS 11, *)
@main
struct ObservabilityWatchApp: App {
    @StateObject private var viewModel = WatchDashboardViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.startMonitoring()
                }
                .onDisappear {
                    viewModel.stopMonitoring()
                }
        }
    }
}

