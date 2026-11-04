import SwiftData
import SwiftUI

/// Domovská obrazovka: nastavení hry a výběr režimu (F4).
struct HomeView: View {
    // F4: nastavení přežije restart díky `@AppStorage`.
    @AppStorage(GameSettingsKey.region.rawValue) private var region = RegionFilter.world
    @AppStorage(GameSettingsKey.optionCount.rawValue) private var optionCount = 4
    @AppStorage(GameSettingsKey.usesTimer.rawValue) private var usesTimer = false
    @AppStorage(GameSettingsKey.unMembersOnly.rawValue) private var unMembersOnly = true

    var body: some View {
        Form {
            Section("Režim hry") {
                ForEach(GameMode.allCases) { mode in
                    NavigationLink(value: config(for: mode)) {
                        Label(mode.title, systemImage: mode.symbol)
                    }
                    .accessibilityIdentifier("home.start.\(mode.rawValue)")
                }
            }
            Section("Nastavení hry") {
                Picker("Region", selection: $region) {
                    ForEach(RegionFilter.allCases) { region in
                        Text(region.title).tag(region)
                    }
                }
                .accessibilityIdentifier("home.region")
                LabeledContent("Počet možností") {
                    Picker("Počet možností", selection: $optionCount) {
                        Text("4").tag(4)
                        Text("6").tag(6)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize()
                }
                .accessibilityIdentifier("home.optionCount")
                Toggle("Časovač 15 sekund", isOn: $usesTimer)
                    .accessibilityIdentifier("home.timer")
                Toggle("Jen členské státy OSN", isOn: $unMembersOnly)
                    .accessibilityIdentifier("home.unOnly")
            }
        }
        .navigationTitle("Vlajkař")
        .navigationDestination(for: GameConfig.self) { config in
            GameScreen(config: config)
        }
    }

    private func config(for mode: GameMode) -> GameConfig {
        GameConfig(
            mode: mode,
            region: region,
            optionCount: optionCount,
            usesTimer: usesTimer,
            unMembersOnly: unMembersOnly
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
#endif
