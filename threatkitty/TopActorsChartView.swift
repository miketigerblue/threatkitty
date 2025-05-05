//
//  TopActorsChartView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  Horizontal bars for top threat actors

import SwiftUI
import Charts

struct TopActorsChartView: View {
    let data: [ActorCount]

    var body: some View {
        ChartSection("Top Threat Actors") {
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Actor", item.actor)
                    )
                    .foregroundStyle(.cyan)
                }
                .chartYAxis { AxisMarks(position: .leading) }
                .chartXAxis { AxisMarks() }
            }
        }
    }
}
