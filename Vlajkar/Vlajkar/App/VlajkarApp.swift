import SwiftData
import SwiftUI

@main
struct VlajkarApp: App {
    @State private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
        }
        .modelContainer(dependencies.container)
    }
}
