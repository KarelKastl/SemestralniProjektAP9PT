import SwiftData
import SwiftUI

/// Výsledek hry (F5 přidá uložení a historii).
struct ResultView: View {
    let engine: GameEngine

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("\(engine.score) / \(engine.total)")
                .font(.largeTitle.bold())
                .accessibilityIdentifier("result.score")
            Button("Zpět na hlavní obrazovku") { dismiss() }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("result.done")
        }
        .padding()
        .navigationBarBackButtonHidden()
        .navigationTitle("Výsledek")
    }
}

#Preview {
    NavigationStack {
        ResultView(engine: PreviewData.engine)
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
