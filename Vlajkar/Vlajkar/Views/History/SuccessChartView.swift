import Charts
import SwiftData
import SwiftUI

/// Úspěšnost v čase (B2). Jedna řada, takže stačí nadpis sekce a legenda není potřeba.
struct SuccessChartView: View {
    let points: [SuccessPoint]

    var body: some View {
        Chart(points) { point in
            LineMark(x: .value("Datum", point.date), y: .value("Úspěšnost", point.percent))
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: 2))
            PointMark(x: .value("Datum", point.date), y: .value("Úspěšnost", point.percent))
                .symbolSize(40)
                .accessibilityLabel(Formatting.date(point.date))
                .accessibilityValue("\(point.percent) procent")
        }
        .chartYScale(domain: 0 ... 100)
        .chartYAxis {
            AxisMarks(values: [0, 50, 100]) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                AxisValueLabel {
                    if let percent = value.as(Int.self) { Text("\(percent) %") }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 3)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(Date.FormatStyle().day().month(.defaultDigits).locale(Formatting.czech)))
                    }
                }
            }
        }
        .frame(minHeight: 160)
        .accessibilityIdentifier("history.chart")
    }
}

#if DEBUG
#Preview {
    SuccessChartView(points: [
        SuccessPoint(id: 0, date: .now.addingTimeInterval(-86_400 * 3), percent: 40),
        SuccessPoint(id: 1, date: .now.addingTimeInterval(-86_400), percent: 70),
        SuccessPoint(id: 2, date: .now, percent: 90),
    ])
    .padding()
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
