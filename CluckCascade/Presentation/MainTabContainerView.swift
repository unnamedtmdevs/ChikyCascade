import SwiftUI

struct MainTabContainerView: View {
    @EnvironmentObject private var gameService: GameService
    @EnvironmentObject private var boostsService: BoostsService
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var selection: AppTab = .home

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Group {
                    switch selection {
                    case .home:
                        HomeView()
                    case .shop:
                        ShopView()
                    case .medals:
                        MedalsView()
                    case .progress:
                        ProgressScreen()
                    case .settings:
                        SettingsView()
                    }
                }

                CustomTabBarView(
                    tabs: AppTab.allCases,
                    selection: $selection
                ) { _ in
                    settingsStore.playTapFeedback()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
