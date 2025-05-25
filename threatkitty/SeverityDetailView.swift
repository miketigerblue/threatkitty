//
//  SeverityDetailView.swift
//  threatkitty
//
//  Full-screen list for a single severity level
//

import SwiftUI

struct SeverityDetailView: View {
    let severity: String          // e.g. "HIGH"
    let entries: [AnalysisEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(entries) { entry in
                NavigationLink(value: entry) {
                    ThreatRowView(entry: entry)
                }
            }
            .navigationTitle("\(severity.capitalized) Threats")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .navigationDestination(for: AnalysisEntry.self) { entry in
                ThreatDetailView(entry: entry)
            }
        }
        // iOS 16+ API for sheet style
        .presentationBackground(.ultraThinMaterial)
        .presentationCornerRadius(16)
    }
}

