//
//  DailyTimelineChartView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
// Area chart spanning full selected window

import SwiftUI
import Charts

struct DailyTimelineChartView: View {
    let data: [DateCount]

    var body: some View {
        ChartSection("Daily Threat Timeline") {
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(data) { item in
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Count", item.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.red.opacity(0.6), .red.opacity(0.1)]),
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                }
                .chartXScale(domain:
                    ClosedRange(
                        uncheckedBounds: (
                            lower: data.first!.date,
                            upper: data.last!.date
                        )
                    )
                )
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { m in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartYAxis { AxisMarks(position: .leading) }
            }
        }
    }
}
