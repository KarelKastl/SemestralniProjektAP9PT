import AppIntents
import Foundation

/// Požadavek zvenku: otevřít denní výzvu při příštím zobrazení aplikace (B3).
nonisolated enum DailyChallengeRequest {
    static let key = "intent.playDaily"
    static let notification = Notification.Name("vlajkar.playDaily")

    /// Uloží požadavek a dá vědět běžící aplikaci. `perform()` může doběhnout až po zobrazení scény.
    static func make(in defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: key)
        NotificationCenter.default.post(name: notification, object: nil)
    }

    /// Vrátí požadavek jen jednou.
    static func consume(in defaults: UserDefaults = .standard) -> Bool {
        guard defaults.bool(forKey: key) else { return false }
        defaults.removeObject(forKey: key)
        return true
    }
}

/// Akce pro Zkratky a Siri, otevře aplikaci rovnou do hry (B3).
struct PlayDailyChallengeIntent: AppIntent {
    static let title: LocalizedStringResource = "Zahraj denní výzvu"
    static let description = IntentDescription("Otevře Vlajkaře a spustí dnešní denní výzvu.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        DailyChallengeRequest.make()
        return .result()
    }
}

struct VlajkarShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlayDailyChallengeIntent(),
            phrases: [
                "Zahraj denní výzvu v aplikaci \(.applicationName)",
                "Spusť denní výzvu v aplikaci \(.applicationName)",
            ],
            shortTitle: "Denní výzva",
            systemImageName: "calendar"
        )
    }
}
