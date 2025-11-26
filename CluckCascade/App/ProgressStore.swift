import Combine
import Foundation

final class ProgressStore: ObservableObject {
    @Published private(set) var progress: PlayerProgress
    @Published private(set) var achievements: [Achievement]

    private let storage: StorageServicing

    init(storage: StorageServicing) {
        self.storage = storage
        self.progress = storage.value(forKey: UserDefaultsKeys.levelProgress, default: PlayerProgress.initial)
        self.achievements = storage.value(forKey: UserDefaultsKeys.achievements, default: [])
    }

    func refresh(with updatedProgress: PlayerProgress) {
        progress = updatedProgress
        storage.set(updatedProgress, forKey: UserDefaultsKeys.levelProgress)
    }

    func updateAchievements(_ newAchievements: [Achievement]) {
        achievements = newAchievements
        storage.set(newAchievements, forKey: UserDefaultsKeys.achievements)
    }
}



