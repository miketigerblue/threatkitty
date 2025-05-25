//
//  SeverityChartView.swift
//  threatkitty
//
//  Created by Mike Harris on 04/05/2025.
//
//  Bar chart for threats by severity.
//

import SwiftUI
import Charts

struct SeverityChartView: View {
    let data: [SeverityCount]
    let onSelectSeverity: (String) -> Void

    var body: some View {
        ChartSection("Threats by Severity") {
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
            } else {
                Chart(data, id: \.severity) { item in
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
                .frame(height: 180)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        if let frameAnchor = proxy.plotFrame {
                            let plotArea: CGRect = geo[frameAnchor]
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            let loc = value.location
                                            let xInPlot = loc.x - plotArea.minX
                                            guard xInPlot >= 0, xInPlot <= plotArea.width else { return }
                                            if let sev: String = proxy.value(atX: xInPlot, as: String.self) {
                                                onSelectSeverity(sev.uppercased())
                                            }
                                        }
                                )
                        }
                    }
                }
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
