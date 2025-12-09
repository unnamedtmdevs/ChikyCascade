import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var settingsStore: SettingsStore
    @StateObject private var attributionViewModel = AttributionViewModel()

    var body: some View {
        Group {
            if attributionViewModel.isCheckingAttribution {
                // Показываем загрузку пока проверяем атрибуцию AppsFlyer
                AttributionLoadingView()
            } else if attributionViewModel.shouldShowWebView, let campaignURL = attributionViewModel.campaignURL {
                // Неорганическая установка - показываем WebView с кампанией
                CampaignWebView(campaignURL: campaignURL)
            } else {
                // Органическая установка - показываем обычное приложение
                normalAppFlow
            }
        }
        .environment(\.animationsEnabled, settingsStore.animationsEnabled)
    }
    
    private var normalAppFlow: some View {
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
    }
}

private struct AttributionLoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.appColors.accentPrimary))
                    .scaleEffect(1.5)
                
                Text("ChikyCascade")
                    .font(AppTypography.title(weight: .bold))
                    .foregroundColor(Color.appColors.textPrimary)
            }
        }
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
