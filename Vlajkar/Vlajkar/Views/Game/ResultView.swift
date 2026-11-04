import SwiftData
import SwiftUI

/// Výsledek hry. Uloží se jednou, i když se view znovu zobrazí (F5).
struct ResultView: View {
    let engine: GameEngine
    let onPlayAgain: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isNewRecord = false
    @State private var savedEngineID: ObjectIdentifier?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(engine.score) / \(engine.total)")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .accessibilityIdentifier("result.score")
                if isNewRecord {
                    Label("Nový rekord!", systemImage: "trophy.fill")
                        .font(.title3.bold())
                        .foregroundStyle(.orange)
                        .accessibilityIdentifier("result.record")
                }
                VStack(spacing: 8) {
                    LabeledContent("Nejlepší série", value: String(engine.bestStreak))
                    LabeledContent("Čas", value: Formatting.duration(engine.duration))
                    LabeledContent("Režim", value: engine.config.mode.title)
                    LabeledContent("Region", value: engine.config.region.title)
                }
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                Button("Hrát znovu", action: onPlayAgain)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityIdentifier("result.again")
                Button("Hotovo") { dismiss() }
                    .accessibilityIdentifier("result.done")
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Výsledek")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: ObjectIdentifier(engine)) { save() }
    }

    private func save() {
        let id = ObjectIdentifier(engine)
        guard savedEngineID != id else { return }
        savedEngineID = id
        isNewRecord = (try? ProgressRecorder.save(engine.summary, in: modelContext)) ?? false
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ResultView(engine: PreviewData.engine, onPlayAgain: {})
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
