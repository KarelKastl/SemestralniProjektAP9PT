import Combine
import SwiftData
import SwiftUI

/// Hlavní navigace aplikace.
struct MainTabView: View {
    private enum Tab: Hashable {
        case game, history, atlas, settings
    }

    @Environment(\.scenePhase) private var scenePhase
    @Query(filter: #Predicate<GameResult> { $0.isDaily }) private var dailyResults: [GameResult]
    @State private var selection = Tab.game
    @State private var gamePath: [GameConfig] = []

    var body: some View {
        TabView(selection: $selection) {
            NavigationStack(path: $gamePath) {
                HomeView()
                    .navigationDestination(for: GameConfig.self) { config in
                        GameScreen(config: config)
                    }
            }
            .tabItem { Label("Hra", systemImage: "flag.fill") }
            .tag(Tab.game)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("Historie", systemImage: "clock") }
            .tag(Tab.history)

            NavigationStack {
                AtlasView()
            }
            .tabItem { Label("Atlas", systemImage: "globe.europe.africa") }
            .tag(Tab.atlas)

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Nastavení", systemImage: "gearshape") }
            .tag(Tab.settings)
        }
        .task { openRequestedDailyChallenge() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { openRequestedDailyChallenge() }
        }
        // B3: spuštění ze Zkratek přijde často až po aktivaci scény, `task` by ho minul.
        .onReceive(NotificationCenter.default.publisher(for: DailyChallengeRequest.notification)) { _ in
            openRequestedDailyChallenge()
        }
    }

    /// B3: Zkratky a Siri otevřou denní výzvu, odehranou výzvu ale znovu nespustí.
    private func openRequestedDailyChallenge() {
        guard DailyChallengeRequest.consume() else { return }
        selection = .game
        gamePath = DailyChallenge.result(in: dailyResults, on: .now) == nil ? [DailyChallenge.config] : []
    }
}

#if DEBUG
#Preview {
    MainTabView()
        .environment(PreviewData.dependencies)
        .modelContainer(PreviewData.dependencies.container)
}
#endif
