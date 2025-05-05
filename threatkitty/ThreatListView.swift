import SwiftUI

struct ThreatListView: View {
    let entries: [AnalysisEntry]
    let severityFilter: String

    /// Filter entries by selected severity ("All" means no filtering)
    private var filteredEntries: [AnalysisEntry] {
        guard severityFilter.uppercased() != "ALL" else {
            return entries
        }
        return entries.filter { $0.severityLevel.uppercased() == severityFilter.uppercased() }
    }

    /// Group the filtered entries by the start of their analysedAt day
    private var groupedByDate: [(key: Date, value: [AnalysisEntry])] {
        Dictionary(grouping: filteredEntries, by: {
            Calendar.current.startOfDay(for: $0.analysedAt)
        })
        .sorted { $0.key > $1.key }
    }

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Threat Timeline")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink, .purple]),
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .padding(.horizontal)

            ForEach(groupedByDate, id: \.key) { date, dayEntries in
                Section(header:
                    Text(dateFormatter.string(from: date))
                        .font(.headline)
                        .padding(.horizontal)
                ) {
                    ForEach(dayEntries) { entry in
                        NavigationLink(value: entry) {
                            ThreatRowView(entry: entry)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct ThreatRowView: View {
    let entry: AnalysisEntry

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack {
                    Text(entry.severityLevel.capitalized)
                        .font(.caption2).bold()
                        .padding(4)
                        .background(color(for: entry.severityLevel))
                        .cornerRadius(4)

                    Spacer()

                    Text("Conf: \(entry.confidencePct)%")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }

    private func color(for sev: String) -> Color {
        switch sev.uppercased() {
            case "LOW":      return .green
            case "MEDIUM":   return .yellow
            case "HIGH":     return .red
            case "CRITICAL": return .purple
            default:          return .white
        }
    }
}
