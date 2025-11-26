import Combine
import Foundation

enum AppRoute {
    case loading
    case onboarding
    case main
}

final class AppCoordinator: ObservableObject {
    @Published private(set) var route: AppRoute = .loading

    let gameService: GameService
    let boostsService: BoostsService
    let settingsStore: SettingsStore
    let progressStore: ProgressStore

    private let storage: StorageServicing
    private let achievementsService: AchievementsServicing
    private var cancellables = Set<AnyCancellable>()

    init(
        storage: StorageServicing,
        gameService: GameService,
        boostsService: BoostsService,
        settingsStore: SettingsStore,
        progressStore: ProgressStore,
        achievementsService: AchievementsServicing
    ) {
        self.storage = storage
        self.gameService = gameService
        self.boostsService = boostsService
        self.settingsStore = settingsStore
        self.progressStore = progressStore
        self.achievementsService = achievementsService

        observeProgress()
        resolveInitialRoute()
        refreshAchievements(with: progressStore.progress)
    }

    func resolveInitialRoute() {
        route = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            let hasSeenOnboarding = self.storage.value(forKey: UserDefaultsKeys.hasSeenOnboarding, default: false)
            self.route = hasSeenOnboarding ? .main : .onboarding
        }
    }

    func completeOnboarding() {
        storage.set(true, forKey: UserDefaultsKeys.hasSeenOnboarding)
        route = .main
    }

    func resetProgress() {
        storage.clear()
        progressStore.refresh(with: PlayerProgress.initial)
        refreshAchievements(with: PlayerProgress.initial)
        boostsService.reset()
        settingsStore.setHaptics(enabled: true)
        settingsStore.setAnimations(enabled: true)
        route = .main
    }

    private func observeProgress() {
        gameService.$playerProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updated in
                guard let self = self else { return }
                self.progressStore.refresh(with: updated)
                self.refreshAchievements(with: updated)
                self.boostsService.refreshInventory(progress: updated)
            }
            .store(in: &cancellables)
    }

    private func refreshAchievements(with progress: PlayerProgress) {
        let updated = achievementsService.evaluate(progress: progress, existing: progressStore.achievements)
        progressStore.updateAchievements(updated)
    }
}

