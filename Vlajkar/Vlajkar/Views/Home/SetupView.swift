import SwiftData
import SwiftUI

/// První spuštění: stažení dat, průběh a chyba s tlačítkem Zkusit znovu (F1).
struct SetupView: View {
    @Binding var isSettingUp: Bool
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "flag.2.crossed.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)
            Text("Vlajkař")
                .font(.largeTitle.bold())
            content
        }
        .padding(24)
        .task { await start() }
    }

    @ViewBuilder
    private var content: some View {
        switch dependencies.sync.phase {
        case .idle:
            ProgressView("Připravuji…")
        case .downloadingCountries:
            ProgressView("Stahuji seznam zemí…")
                .accessibilityIdentifier("setup.countries")
        case let .downloadingFlags(done, total):
            ProgressView("Stahuji vlajky \(done)/\(total)", value: Double(done), total: Double(max(total, 1)))
                .accessibilityIdentifier("setup.flags")
        case let .failed(message):
            failure(message)
        case .finished:
            ProgressView("Hotovo")
                .task { isSettingUp = false }
        }
    }

    private func failure(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("setup.error")
            Button("Zkusit znovu") {
                Task { await run() }
            }
            .buttonStyle(.borderedProminent)
            Button("Pokračovat s přibalenými daty") {
                dependencies.sync.useBundledData(context: modelContext)
            }
            Text("Přibalená data neobsahují vlajky, režim Vlajka bude dostupný po aktualizaci dat.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func start() async {
        guard dependencies.sync.phase == .idle else { return }
        await run()
    }

    private func run() async {
        isSettingUp = true
        await dependencies.sync.sync(context: modelContext)
    }
}

#Preview {
    SetupView(isSettingUp: .constant(true))
        .environment(AppDependencies(options: LaunchOptions(usesFixtures: true, isOffline: true)))
        .modelContainer(for: [Country.self, GameResult.self], inMemory: true)
}
