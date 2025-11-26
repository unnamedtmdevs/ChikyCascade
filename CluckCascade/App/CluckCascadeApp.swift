import SwiftUI

@main
struct CluckCascadeApp: App {
    @StateObject private var coordinator: AppCoordinator
    @StateObject private var gameService: GameService
    @StateObject private var boostsService: BoostsService
    @StateObject private var settingsStore: SettingsStore
    @StateObject private var progressStore: ProgressStore

    init() {
        let storage = StorageService()
        let cascadeService = CascadeSolverService()
        let levelService = LevelService()
        let hapticsService = HapticsService(storage: storage)
        let achievementsService = AchievementsService()
        let gameService = GameService(
            levelService: levelService,
            cascadeService: cascadeService,
            storage: storage,
            haptics: hapticsService
        )
        let boostsService = BoostsService(storage: storage)
        let settingsStore = SettingsStore(
            storage: storage,
            hapticsService: hapticsService
        )
        let progressStore = ProgressStore(storage: storage)

        let coordinator = AppCoordinator(
            storage: storage,
            gameService: gameService,
            boostsService: boostsService,
            settingsStore: settingsStore,
            progressStore: progressStore,
            achievementsService: achievementsService
        )

        _gameService = StateObject(wrappedValue: gameService)
        _boostsService = StateObject(wrappedValue: boostsService)
        _settingsStore = StateObject(wrappedValue: settingsStore)
        _progressStore = StateObject(wrappedValue: progressStore)
        _coordinator = StateObject(wrappedValue: coordinator)

        NavAppearance.applyTransparentBars()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(coordinator)
                .environmentObject(gameService)
                .environmentObject(boostsService)
                .environmentObject(settingsStore)
                .environmentObject(progressStore)
        }
    }
}
