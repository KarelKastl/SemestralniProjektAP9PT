import SwiftData
import SwiftUI

/// Hlavní navigace aplikace.
struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Hra", systemImage: "flag.fill") }

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("Historie", systemImage: "clock") }

            NavigationStack {
                AtlasView()
            }
            .tabItem { Label("Atlas", systemImage: "globe.europe.africa") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Nastavení", systemImage: "gearshape") }
        }
    }
}

#Preview {
    MainTabView()
        .environment(PreviewData.dependencies)
        .modelContainer(PreviewData.dependencies.container)
}
