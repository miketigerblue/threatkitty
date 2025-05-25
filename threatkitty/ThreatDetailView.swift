//
//  ThreatDetailView.swift
//  threatkitty
//
//  Full‐screen detailed analysis page for one entry, supporting all 2025 fields.
//

import SwiftUI

struct ThreatDetailView: View {
    let entry: AnalysisEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(entry.title)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                // Severity & published date
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

                // Main content/summary (nullable in API)
                if let content = entry.content, !content.isEmpty {
                    Text(content)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }

                // Contextual meta-fields
                metaSection(title: "Summary Impact", value: entry.summaryImpact)
                metaSection(title: "Historical Context", value: entry.historicalContext)
                metaSection(title: "Relevance", value: entry.relevance)
                metaSection(title: "Additional Notes", value: entry.additionalNotes)

                // Indicators of Compromise (IoCs)
                if !entry.keyIOCs.isEmpty {
                    section(title: "Indicators of Compromise") {
                        ForEach(entry.keyIOCs, id: \.self) { ioc in
                            Text("• \(ioc)")
                        }
                    }
                }

                // Recommended Actions
                if !entry.recommendedActions.isEmpty {
                    section(title: "Recommended Actions") {
                        ForEach(entry.recommendedActions, id: \.self) { action in
                            Text("• \(action)")
                        }
                    }
                }

                // Mitigation Strategies
                if !entry.mitigationStrategies.isEmpty {
                    section(title: "Mitigation Strategies") {
                        ForEach(entry.mitigationStrategies, id: \.self) { ms in
                            Text("• \(ms)")
                        }
                    }
                }

                // CVE References
                if !entry.cveReferences.isEmpty {
                    section(title: "CVE References") {
                        ForEach(entry.cveReferences, id: \.self) { cve in
                            Text("• \(cve)")
                        }
                    }
                }

                // MITRE ATT&CK Techniques
                if !entry.ttps.isEmpty {
                    section(title: "MITRE ATT&CK Techniques") {
                        ForEach(entry.ttps, id: \.self) { ttp in
                            Text("• \(ttp)")
                        }
                    }
                }

                // Attack Vectors
                if !entry.attackVectors.isEmpty {
                    section(title: "Attack Vectors") {
                        ForEach(entry.attackVectors, id: \.self) { av in
                            Text("• \(av)")
                        }
                    }
                }

                // Tools Used
                if !entry.toolsUsed.isEmpty {
                    section(title: "Tools Used") {
                        ForEach(entry.toolsUsed, id: \.self) { tool in
                            Text("• \(tool)")
                        }
                    }
                }

                // Malware Families
                if !entry.malwareFamilies.isEmpty {
                    section(title: "Malware Families") {
                        ForEach(entry.malwareFamilies, id: \.self) { malware in
                            Text("• \(malware)")
                        }
                    }
                }

                // Target Geographies
                if !entry.targetGeographies.isEmpty {
                    section(title: "Target Geographies") {
                        ForEach(entry.targetGeographies, id: \.self) { geo in
                            Text("• \(geo)")
                        }
                    }
                }

                // Exploit References as clickable links (if URLs)
                if !entry.exploitReferences.isEmpty {
                    section(title: "Exploit References") {
                        ForEach(entry.exploitReferences, id: \.self) { ref in
                            if let url = URL(string: ref), UIApplication.shared.canOpenURL(url) {
                                Link(destination: url) {
                                    Text(url.absoluteString)
                                        .foregroundColor(.cyan)
                                        .underline()
                                }
                            } else {
                                Text("• \(ref)")
                            }
                        }
                    }
                }

                // Feed/Source Metadata
                if entry.feedTitle != nil || entry.feedDescription != nil || entry.feedLanguage != nil {
                    section(title: "Feed Source") {
                        VStack(alignment: .leading, spacing: 4) {
                            if let feedTitle = entry.feedTitle {
                                Text(feedTitle).bold()
                            }
                            if let feedDesc = entry.feedDescription {
                                Text(feedDesc)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if let feedLang = entry.feedLanguage {
                                Text("Language: \(feedLang)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            if let feedIcon = entry.feedIcon,
                               let iconURL = URL(string: feedIcon) {
                                AsyncImage(url: iconURL) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }

                // Affected Sectors/Systems
                if !entry.affectedSystemsSectors.isEmpty {
                    section(title: "Affected Systems/Sectors") {
                        ForEach(entry.affectedSystemsSectors, id: \.self) { sys in
                            Text("• \(sys)")
                        }
                    }
                }

                // Potential Threat Actors
                if !entry.potentialThreatActors.isEmpty {
                    section(title: "Potential Threat Actors") {
                        ForEach(entry.potentialThreatActors, id: \.self) { actor in
                            Text("• \(actor)")
                        }
                    }
                }

                Spacer()
            }
            .padding(.vertical)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }

    // MARK: - Helper: Meta section for one-liner fields
    @ViewBuilder
    private func metaSection(title: String, value: String?) -> some View {
        if let v = value, !v.isEmpty {
            section(title: title) { Text(v) }
        }
    }

    // MARK: - Helper: Section UI
    @ViewBuilder
    private func section<Content: View>(
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

    // MARK: - Helper: Severity badge colour
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
