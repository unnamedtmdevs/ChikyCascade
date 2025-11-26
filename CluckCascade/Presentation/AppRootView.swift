import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var settingsStore: SettingsStore

    var body: some View {
        Group {
            switch coordinator.route {
            case .loading:
                LoadingView()
            case .onboarding:
                OnboardingFlowView(onComplete: coordinator.completeOnboarding)
            case .main:
                MainTabContainerView()
            }
        }
        .environment(\.animationsEnabled, settingsStore.animationsEnabled)
    }
}

private struct AnimationsEnabledEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

extension EnvironmentValues {
    var animationsEnabled: Bool {
        get { self[AnimationsEnabledEnvironmentKey.self] }
        set { self[AnimationsEnabledEnvironmentKey.self] = newValue }
    }
}
