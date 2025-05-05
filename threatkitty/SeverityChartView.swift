//
//  SeverityChartView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  Bar chart with totals on top

import SwiftUI
import Charts

struct SeverityChartView: View {
    let data: [SeverityCount]

    var body: some View {
        ChartSection("Threats by Severity") {
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Severity", item.severity),
                        y: .value("Count",    item.count)
                    )
                    .foregroundStyle(color(for: item.severity))
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption2).bold()
                            .foregroundColor(.white)
                    }
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .chartXAxis { AxisMarks() }
            }
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
