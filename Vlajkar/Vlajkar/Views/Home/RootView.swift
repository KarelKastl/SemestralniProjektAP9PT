import SwiftData
import SwiftUI

/// Kořen aplikace.
struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
    }
}

#Preview {
    RootView()
        .environment(AppDependencies(options: LaunchOptions(usesFixtures: true)))
        .modelContainer(for: [Country.self, GameResult.self], inMemory: true)
}
