//
//  DashboardView.swift
//  threatkitty
//
//  Main SwiftUI dashboard.
//

import SwiftUI
import Charts

/// The main dashboard aggregating all threat visualisations
struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var selectedSeverity = "All"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date Range Picker
                    Picker("Date Range", selection: $vm.dateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.displayName).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Severity Picker
                    Picker("Severity", selection: $selectedSeverity) {
                        Text("All").tag("All")
                        ForEach(["CRITICAL", "HIGH", "MEDIUM", "LOW"], id: \.self) { sev in
                            Text(sev.capitalized).tag(sev)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Severity Distribution Chart
                    SeverityChartView(
                        data: vm.severityDist,
                        onSelectSeverity: { sev in
                            selectedSeverity = sev
                        }
                    )
                    .padding(.horizontal)

                    // Top Threat Actors
                    TopActorsChartView(data: Array(vm.topActors.prefix(8)))
                        .padding(.horizontal)

                    // Daily Threat Timeline
                    DailyTimelineChartView(data: vm.timeline)
                        .padding(.horizontal)

                    // Top CVEs
                    TopCVEsView(data: Array(vm.topCVEs.prefix(6)))
                        .padding(.horizontal)

                    // Critical Alerts Over Time
                    CriticalTimelineChartView(data: vm.criticalTimeline)
                        .padding(.horizontal)

                    // Threat List (Timeline Table)
                    ThreatListView(
                        entries: vm.filteredEntries,
                        severityFilter: selectedSeverity
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("⚡️ Threat Kitty")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Replace "cat" with your asset name or use an SF Symbol (e.g. "pawprint")
                    Image("TK")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                        .padding(.trailing, 2)
                        .accessibilityLabel("Mieow")
                }
            }
            .task { await vm.loadData() }
            .navigationDestination(for: AnalysisEntry.self) { entry in
                ThreatDetailView(entry: entry)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .preferredColorScheme(.dark)
    }
}
