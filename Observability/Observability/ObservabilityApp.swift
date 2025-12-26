//
//  ObservabilityApp.swift
//  Observability
//
//  Created by admin-macbook on 12/15/25.
//

import SwiftUI

@main
struct ObservabilityApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
    }
}
