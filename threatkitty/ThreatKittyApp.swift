//
//  ThreatKittyApp.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//


// ThreatKittyApp.swift
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
