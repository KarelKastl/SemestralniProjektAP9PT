import SwiftData
import SwiftUI

/// Nastavení aplikace a obnovení dat (F7).
struct SettingsView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @Query private var countries: [Country]

    var body: some View {
        Form {
            Section("Data zemí") {
                LabeledContent("Uložené země", value: String(countries.count))
                    .accessibilityIdentifier("settings.count")
                LabeledContent("Vlajky", value: String(countries.filter { $0.flagPNG != nil }.count))
                Button("Aktualizovat data zemí") {
                    Task { await dependencies.sync.sync(context: modelContext) }
                }
                .disabled(dependencies.sync.phase.isRunning)
                .accessibilityIdentifier("settings.refresh")
                status
            }
            Section("O aplikaci") {
                LabeledContent("Zdroj dat", value: "REST Countries")
                Text("Objevené země a historie her se aktualizací nesmažou.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Nastavení")
    }

    @ViewBuilder
    private var status: some View {
        switch dependencies.sync.phase {
        case .idle:
            EmptyView()
        case .downloadingCountries:
            ProgressView("Stahuji seznam zemí…")
        case let .downloadingFlags(done, total):
            ProgressView("Stahuji vlajky \(done)/\(total)", value: Double(done), total: Double(max(total, 1)))
        case let .failed(message):
            Text(message)
                .foregroundStyle(.red)
                .accessibilityIdentifier("settings.error")
        case let .finished(summary):
            Text("Aktualizováno \(summary.updated), přidáno \(summary.added)")
                .accessibilityIdentifier("settings.result")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(PreviewData.dependencies)
    .modelContainer(PreviewData.dependencies.container)
}
