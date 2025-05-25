//
//  TopActorsChartView.swift
//  threatkitty
//
//  Horizontal bars for top threat actors
//
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
                Chart(data.prefix(12)) { item in  // Increase to 12 for demonstration
                    BarMark(
                        x: .value("Count", item.count),
                        y: .value("Actor", item.actor)
                    )
                    .foregroundStyle(.cyan)
                    .annotation(position: .trailing) {
                        Text("\(item.count)")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            let idx = value.index
                            if idx < data.prefix(12).count {
                                let name = data.prefix(12)[idx].actor
                                Text(name)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .chartScrollableAxes(.vertical)
                .frame(height: min(CGFloat(data.prefix(12).count) * 32 + 32, 350)) // Scroll if longer
                .padding()
            }
        }
    }
}

