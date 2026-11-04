import Foundation

/// Česká čísla a časy (pravidlo 8).
nonisolated enum Formatting {
    static let czech = Locale(identifier: "cs_CZ")

    static func number(_ value: Int) -> String {
        value.formatted(.number.locale(czech))
    }

    static func date(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(czech))
    }

    static func duration(_ seconds: TimeInterval) -> String {
        let total = max(Int(seconds.rounded()), 0)
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }
}
