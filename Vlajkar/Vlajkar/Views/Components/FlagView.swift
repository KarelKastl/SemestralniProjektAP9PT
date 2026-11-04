import SwiftData
import SwiftUI

/// Vlajka z databáze. Funguje offline a popisek určuje rodič.
struct FlagView: View {
    let code: String
    var pixelWidth: CGFloat = 640

    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay {
                        RoundedRectangle(cornerRadius: 6).stroke(.quaternary)
                    }
            } else {
                Image(systemName: "flag.slash")
                    .font(.title)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: code) {
            image = await dependencies.flagCache.image(code: code, pixelWidth: pixelWidth, context: modelContext)
        }
    }
}

#Preview {
    FlagView(code: "CZE")
        .environment(PreviewData.dependencies)
        .modelContainer(PreviewData.dependencies.container)
}
