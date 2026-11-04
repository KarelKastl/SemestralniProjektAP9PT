import SwiftData
import SwiftUI

/// Vytvoří hru, zobrazí ji a po dokončení ukáže výsledek.
struct GameScreen: View {
    let config: GameConfig

    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var engine: GameEngine?

    var body: some View {
        Group {
            if let engine {
                if engine.total == 0 {
                    ContentUnavailableView(
                        "Tato hra teď nejde spustit",
                        systemImage: "exclamationmark.triangle",
                        description: Text(emptyMessage)
                    )
                } else if engine.isFinished {
                    ResultView(engine: engine, onPlayAgain: startNewGame)
                } else {
                    GameView(engine: engine)
                }
            } else {
                ProgressView()
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .task {
            // Hra vznikne jen jednou, návrat na obrazovku ji nerestartuje.
            if engine == nil { startNewGame() }
        }
    }

    private func startNewGame() {
        engine = dependencies.makeEngine(config: config, context: modelContext)
    }

    private var emptyMessage: String {
        config.mode == .flag
            ? "Chybí vlajky. Aktualizujte data zemí v Nastavení nebo změňte region."
            : "Pro zvolené nastavení není dost zemí."
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        GameScreen(config: GameConfig(mode: .flag))
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
