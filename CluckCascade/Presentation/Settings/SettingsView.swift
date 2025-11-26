import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var showingResetAlert = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FallingChickensBackground(density: 5, sizeRange: 34...48, speedRange: 16...28, opacity: 0.32)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    feedbackSection
                    dataManagementSection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 120)
                .maxContentWidth()
            }
            .padding(.bottom, 70)
        }
        .keyboardDismissable()
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                coordinator.resetProgress()
            }
        } message: {
            Text("This will clear all saved progress, boosts, and settings. Are you sure?")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Coop Settings")
                .font(AppTypography.display())
                .foregroundColor(Color.appColors.textPrimary)
            Text("Tailor the farmhouse experience, manage data, and explore coop lore.")
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
        }
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Feedback & Effects")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            CoopToggle(
                title: "Haptic Feedback",
                subtitle: "Vibrant taps for buttons, cascades, and celebrations.",
                isOn: Binding(
                    get: { settingsStore.hapticsEnabled },
                    set: { settingsStore.setHaptics(enabled: $0) }
                )
            )

            CoopToggle(
                title: "Animations",
                subtitle: "Enable farmhouse flourishes for transitions and cascades.",
                isOn: Binding(
                    get: { settingsStore.animationsEnabled },
                    set: { settingsStore.setAnimations(enabled: $0) }
                )
            )
        }
    }

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Data Management")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            Button {
                showingResetAlert = true
            } label: {
                Text("Reset Progress")
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(WoodButtonStyle(variant: .destructive))
        }
    }
}



