//
//  CriticalTimelineChartView.swift
//  threatkitty
//
//  Line chart for critical-severity alerts over time.
//

import SwiftUI
import Charts

/// Shows a line chart of critical alerts over time
struct CriticalTimelineChartView: View {
    let data: [CriticalAlertCount]

    var body: some View {
        ChartSection("Critical Alerts Over Time") {
            if data.isEmpty {
                Text("No data")
                  .foregroundStyle(.gray)
                  .frame(maxWidth: .infinity, minHeight: 150)
                  .padding()
            } else {
                Chart(data) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(.purple)
                    .symbol(Circle())
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, data.count/5))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
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
