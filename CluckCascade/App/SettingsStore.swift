import Combine
import Foundation

final class SettingsStore: ObservableObject {
    struct UserPreferences: Codable {
        var goalHintsEnabled: Bool
        var colorblindFriendlyPalette: Bool
        var statisticsSummaryEnabled: Bool

        static let `default` = UserPreferences(
            goalHintsEnabled: true,
            colorblindFriendlyPalette: false,
            statisticsSummaryEnabled: true
        )
    }

    enum AnimationPreference: String, Codable {
        case enabled
        case disabled
    }

    @Published private(set) var hapticsEnabled: Bool
    @Published private(set) var animationsEnabled: Bool
    @Published private(set) var preferences: UserPreferences

    private let storage: StorageServicing
    private let hapticsService: HapticsServicing

    init(storage: StorageServicing, hapticsService: HapticsServicing) {
        self.storage = storage
        self.hapticsService = hapticsService
        self.hapticsEnabled = storage.value(forKey: UserDefaultsKeys.hapticsEnabled, default: true)
        self.animationsEnabled = storage.value(forKey: UserDefaultsKeys.animationsEnabled, default: true)
        self.preferences = storage.value(forKey: UserDefaultsKeys.settings, default: UserPreferences.default)

        hapticsService.update(isEnabled: hapticsEnabled)
    }

    func setHaptics(enabled: Bool) {
        guard enabled != hapticsEnabled else { return }
        hapticsEnabled = enabled
        storage.set(enabled, forKey: UserDefaultsKeys.hapticsEnabled)
        hapticsService.update(isEnabled: enabled)
    }

    func setAnimations(enabled: Bool) {
        guard enabled != animationsEnabled else { return }
        animationsEnabled = enabled
        storage.set(enabled, forKey: UserDefaultsKeys.animationsEnabled)
    }

    func playTapFeedback() {
        guard hapticsEnabled else { return }
        hapticsService.lightImpact()
    }

    func setGoalHints(enabled: Bool) {
        guard preferences.goalHintsEnabled != enabled else { return }
        preferences.goalHintsEnabled = enabled
        persistPreferences()
    }

    func setColorblindPalette(enabled: Bool) {
        guard preferences.colorblindFriendlyPalette != enabled else { return }
        preferences.colorblindFriendlyPalette = enabled
        persistPreferences()
    }

    func setStatisticsSummary(enabled: Bool) {
        guard preferences.statisticsSummaryEnabled != enabled else { return }
        preferences.statisticsSummaryEnabled = enabled
        persistPreferences()
    }

    private func persistPreferences() {
        storage.set(preferences, forKey: UserDefaultsKeys.settings)
    }
}

