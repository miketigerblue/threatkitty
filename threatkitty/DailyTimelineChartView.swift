//
//  DailyTimelineChartView.swift
//  threatkitty
//
//  Shows an interactive daily threat timeline as an area+line chart with neon borders.
//

import SwiftUI
import Charts

struct DailyTimelineChartView: View {
    let data: [TimelineDateCount]
    @State private var highlightedPoint: TimelineDateCount? = nil

    var body: some View {
        ChartSection("Daily Threat Timeline") {
            if data.isEmpty {
                Text("No data")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .padding()
            } else {
                Chart {
                    // Area fill
                    ForEach(data) { point in
                        AreaMark(
                            x: .value("Date", point.date),
                            y: .value("Count", point.count)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [.red.opacity(0.3), .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    // Line overlay
                    ForEach(data) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Count", point.count)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(.red)
                    }
                    // Highlighted point & tooltip
                    if let h = highlightedPoint {
                        PointMark(
                            x: .value("Date", h.date),
                            y: .value("Count", h.count)
                        )
                        .symbolSize(80)
                        .foregroundStyle(.white)
                        .annotation(position: .top) {
                            VStack(spacing: 2) {
                                Text(h.date, format: .dateTime.day().month(.narrow))
                                    .font(.caption).bold()
                                Text("\(h.count)")
                                    .font(.caption2)
                            }
                            .padding(6)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, data.count / 5))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [.pink, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let loc = value.location
                                        let anchor = proxy.plotAreaFrame
                                        let plotRect = geo[anchor]
                                        guard plotRect.contains(loc) else { return }
                                        let xPos = loc.x - plotRect.minX
                                        if let date: Date = proxy.value(atX: xPos) {
                                            if let match = data.first(where: {
                                                Calendar.current.isDate($0.date, inSameDayAs: date)
                                            }) {
                                                highlightedPoint = match
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.easeOut) {
                                                highlightedPoint = nil
                                            }
                                        }
                                    }
                            )
                    }
                }

            }
        }
    }
}
