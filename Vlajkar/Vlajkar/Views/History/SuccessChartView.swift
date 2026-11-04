import Charts
import SwiftData
import SwiftUI

/// Úspěšnost v čase (B2). Jedna řada, takže stačí nadpis sekce a legenda není potřeba.
struct SuccessChartView: View {
    let points: [SuccessPoint]

    /// Popisky osy X: první a poslední hra, stejné datum se neopakuje.
    private var axisPoints: [SuccessPoint] {
        guard let first = points.first, let last = points.last else { return [] }
        let isSameDay = Calendar.current.isDate(first.date, inSameDayAs: last.date)
        return isSameDay ? [last] : [first, last]
    }

    var body: some View {
        // Osa X je pořadí her: hry z jednoho dne by se na časové ose slily do jednoho místa.
        Chart(points) { point in
            LineMark(x: .value("Hra", point.id), y: .value("Úspěšnost", point.percent))
                .lineStyle(StrokeStyle(lineWidth: 2))
            PointMark(x: .value("Hra", point.id), y: .value("Úspěšnost", point.percent))
                .symbolSize(40)
                .accessibilityLabel(Formatting.date(point.date))
                .accessibilityValue("\(point.percent) procent")
        }
        .chartYScale(domain: 0 ... 100)
        .chartXScale(domain: 0 ... max(points.count - 1, 1))
        .chartYAxis {
            AxisMarks(values: [0, 50, 100]) { value in
                AxisGridLine().foregroundStyle(.quaternary)
                AxisValueLabel {
                    if let percent = value.as(Int.self) { Text("\(percent) %") }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: axisPoints.map(\.id)) { value in
                AxisValueLabel(anchor: .topTrailing, collisionResolution: .disabled) {
                    if let id = value.as(Int.self), let point = points.first(where: { $0.id == id }) {
                        Text(point.date.formatted(Date.FormatStyle().day().month(.defaultDigits).locale(Formatting.czech)))
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
