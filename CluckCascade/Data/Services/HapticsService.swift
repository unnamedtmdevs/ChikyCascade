import CoreHaptics
import UIKit

protocol HapticsServicing {
    var isEnabled: Bool { get }
    func update(isEnabled: Bool)
    func lightImpact()
    func mediumImpact()
    func heavyImpact()
    func success()
    func warning()
    func error()
}

final class HapticsService: HapticsServicing {
    private var engine: CHHapticEngine?
    private let storage: StorageServicing
    private(set) var isEnabled: Bool

    init(storage: StorageServicing) {
        self.storage = storage
        self.isEnabled = storage.value(forKey: UserDefaultsKeys.hapticsEnabled, default: true)
        prepareEngine()
    }

    func update(isEnabled: Bool) {
        self.isEnabled = isEnabled
        storage.set(isEnabled, forKey: UserDefaultsKeys.hapticsEnabled)
    }

    func lightImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func mediumImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func heavyImpact() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    func success() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }
}



