//
//  ThreatKittyApp.swift
//  threatkitty
//
//  App entry point
//

import SwiftUI

@main
struct ThreatKittyApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .accentColor(.pink)                     // Neon pink accent
                .preferredColorScheme(.dark)            // Always dark mode
        }
    }
}
