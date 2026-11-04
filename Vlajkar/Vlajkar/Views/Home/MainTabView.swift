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
        }
    }
}

#Preview {
    MainTabView()
        .environment(PreviewData.dependencies)
        .modelContainer(PreviewData.dependencies.container)
}
