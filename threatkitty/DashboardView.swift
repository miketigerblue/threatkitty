//
//  DashboardView.swift
//  threatkitty
//
//  Main SwiftUI dashboard: pickers, charts & a navigable timeline.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @State private var selectedSeverity = "All"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ───────────────────────
                    // Date Range Segmented Picker
                    // ───────────────────────
                    Picker("Date Range", selection: $vm.dateRange) {
                        ForEach(DateRange.allCases) { range in
                            Text(range.displayName)
                                .tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    // ───────────────────────
                    // Severity Segmented Picker
                    // ───────────────────────
                    Picker("Severity", selection: $selectedSeverity) {
                        Text("All").tag("All")
                        ForEach(["CRITICAL", "HIGH", "MEDIUM", "LOW"], id: \.self) {
                            Text($0.capitalized).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    // ───────────────────────
                    // Charts
                    // ───────────────────────
                    SeverityChartView(data: vm.severityDist)
                    TopActorsChartView(data: Array(vm.topActors.prefix(8)))
                    DailyTimelineChartView(data: vm.timeline)
                    TopCVEsView(data: Array(vm.topCVEs.prefix(6)))
                    CriticalTimelineChartView(data: vm.criticalTimeline)

                    // ───────────────────────
                    // Threat List
                    // ───────────────────────
                    ThreatListView(
                        entries: vm.filteredEntries,
                        severityFilter: selectedSeverity
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationTitle("Threat Kitty")    // removed ⚡️
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image("TK")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }
            }
            .task { await vm.loadData() }
            .navigationDestination(for: AnalysisEntry.self) { entry in
                ThreatDetailView(entry: entry)
            }
        }
    }
}
