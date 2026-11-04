import SwiftData
import UIKit

/// Dekóduje vlajky mimo hlavní vlákno a drží je v paměti, aby `body` nic nedekódovalo (F8).
final class FlagImageCache {
    private let cache = NSCache<NSString, UIImage>()

    init() {
        cache.countLimit = 300
    }

    func image(code: String, pixelWidth: CGFloat, context: ModelContext) async -> UIImage? {
        let key = "\(code)-\(Int(pixelWidth))" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        var descriptor = FetchDescriptor<Country>(predicate: #Predicate { $0.code == code })
        descriptor.fetchLimit = 1
        guard let data = (try? context.fetch(descriptor).first)?.flagPNG else { return nil }

        let image = await Task.detached(priority: .userInitiated) {
            Self.decode(data, pixelWidth: pixelWidth)
        }.value
        if let image { cache.setObject(image, forKey: key) }
        return image
    }

    private nonisolated static func decode(_ data: Data, pixelWidth: CGFloat) -> UIImage? {
        guard let image = UIImage(data: data), image.size.width > 0 else { return nil }
        guard image.size.width > pixelWidth else { return image.preparingForDisplay() ?? image }
        let scale = pixelWidth / image.size.width
        return image.preparingThumbnail(of: CGSize(width: pixelWidth, height: image.size.height * scale)) ?? image
    }
}
