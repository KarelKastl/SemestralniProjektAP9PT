import SwiftData
import SwiftUI

/// Domovská obrazovka. Herní nabídka přijde ve F3.
struct HomeView: View {
    var body: some View {
        ContentUnavailableView("Vlajkař", systemImage: "flag.fill", description: Text("Zeměpisný kvíz"))
            .navigationTitle("Vlajkař")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: [Country.self, GameResult.self], inMemory: true)
}
