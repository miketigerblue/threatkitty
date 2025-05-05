//
//  ThreatDetailView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  Full‐screen detailed analysis page for one entry

import SwiftUI

struct ThreatDetailView: View {
    let entry: AnalysisEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(entry.title)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                HStack {
                    Text(entry.severityLevel.capitalized)
                        .font(.caption2).bold()
                        .padding(6)
                        .background(color(for: entry.severityLevel))
                        .cornerRadius(6)

                    Spacer()

                    if let pub = entry.published {
                        Text(pub, format: .dateTime.year().month().day().hour().minute())
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                Divider().background(Color.gray)

                Text(entry.content)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                // Indicators
                if !entry.keyIOCs.isEmpty {
                    section(title: "Indicators of Compromise") {
                        ForEach(entry.keyIOCs, id:\.self) { ioc in
                            Text("• \(ioc)")
                        }
                    }
                }

                // Recommended
                if !entry.recommendedActions.isEmpty {
                    section(title: "Recommended Actions") {
                        ForEach(entry.recommendedActions, id:\.self) {
                            Text("• \($0)")
                        }
                    }
                }

                // Mitigation
                if !entry.mitigationStrategies.isEmpty {
                    section(title: "Mitigation Strategies") {
                        ForEach(entry.mitigationStrategies, id:\.self) {
                            Text("• \($0)")
                        }
                    }
                }

                // CVEs
                if !entry.cveReferences.isEmpty {
                    section(title: "CVE References") {
                        ForEach(entry.cveReferences, id:\.self) {
                            Text("• \($0)")
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    @ViewBuilder
    private func section<Content:View>(
        title: String,
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.pink)
                .padding(.horizontal)
            content()
                .foregroundColor(.white)
                .padding(.horizontal)
        }
    }

    private func color(for sev: String) -> Color {
        switch sev.uppercased() {
            case "LOW":      return .green
            case "MEDIUM":   return .yellow
            case "HIGH":     return .red
            case "CRITICAL": return .purple
            default:         return .white
        }
    }
}
