//
//  CriticalTimelineChartView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  Line chart for critical-severity alerts over time, with a placeholder when there’s no data

import SwiftUI
import Charts

struct CriticalTimelineChartView: View {
    let data: [DateCount]

    var body: some View {
        ChartSection("Critical Alerts Over Time") {
            if data.isEmpty {
                // placeholder when there are no critical alerts
                Text("No critical alerts for this period.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
            } else {
                Chart(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .symbol(Circle())
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, data.count / 6))) {
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 180)
                .padding()
            }
        }
    }
}
