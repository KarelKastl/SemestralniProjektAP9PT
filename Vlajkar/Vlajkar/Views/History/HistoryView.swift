import SwiftData
import SwiftUI

/// Historie her a rekordy (F5).
struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameResult.date, order: .reverse) private var results: [GameResult]

    private var points: [SuccessPoint] {
        HistoryStats.successPoints(in: results)
    }

    var body: some View {
        Group {
            if results.isEmpty {
                ContentUnavailableView(
                    "Zatím žádná hra",
                    systemImage: "clock",
                    description: Text("Odehrané hry se zobrazí tady.")
                )
            } else {
                List {
                    if points.count >= 2 {
                        Section("Úspěšnost v čase") {
                            SuccessChartView(points: points)
                        }
                    }
                    Section("Nejlepší skóre") {
                        ForEach(HistoryStats.bestScores(in: results), id: \.mode) { best in
                            LabeledContent(best.mode.title, value: String(best.score))
                        }
                    }
                    Section("Odehrané hry") {
                        ForEach(results) { result in
                            HistoryRow(result: result)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
        }
        .navigationTitle("Historie")
    }

    private func delete(at offsets: IndexSet) {
        // Pravidlo 4: mažeme objekt ze stejného pole, které zobrazuje `ForEach`.
        for index in offsets {
            modelContext.delete(results[index])
        }
        try? modelContext.save()
    }
}

private struct HistoryRow: View {
    let result: GameResult

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(result.isDaily ? "Denní výzva" : result.gameMode.title)
                    .font(.headline)
                Spacer()
                Text("\(result.score) / \(result.total)")
                    .font(.headline)
                    .monospacedDigit()
            }
            Text("\(Formatting.date(result.date)) · \(result.region)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Série \(result.bestStreak) · čas \(Formatting.duration(result.duration))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("history.row")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HistoryView()
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
