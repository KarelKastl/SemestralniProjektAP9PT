import SwiftData
import SwiftUI

/// Kořen aplikace: bez dat ukáže přípravu, jinak domovskou obrazovku.
struct RootView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Query private var countries: [Country]
    // F1: přípravu držíme otevřenou i poté, co se během stahování objeví první záznamy.
    @State private var isSettingUp = false

    var body: some View {
        Group {
            if countries.isEmpty || isSettingUp {
                SetupView(isSettingUp: $isSettingUp)
            } else {
                NavigationStack {
                    HomeView()
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environment(PreviewData.dependencies)
        .modelContainer(PreviewData.dependencies.container)
}
