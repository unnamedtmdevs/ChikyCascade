import SwiftUI

struct ModeSelectionView: View {
    let onSelect: (GameMode) -> Void

    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    private let modes = GameMode.playOptions

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    ForEach(modes) { mode in
                        modeCard(for: mode)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfaceSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Choose Mode")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func modeCard(for mode: GameMode) -> some View {
        Button {
            settingsStore.playTapFeedback()
            onSelect(mode)
            dismiss()
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(alignment: .center, spacing: AppSpacing.sm) {
                    Label(mode.displayName, systemImage: mode.iconName)
                        .labelStyle(.titleAndIcon)
                        .font(AppTypography.headline(weight: .semibold))
                        .foregroundColor(Color.appColors.textPrimary)
                    Spacer()
                    if let badge = mode.badgeText {
                        Text(badge)
                            .font(AppTypography.caption(weight: .medium))
                            .foregroundColor(Color.appColors.textPrimary)
                            .padding(.horizontal, AppSpacing.xs)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.appColors.accentSecondary.opacity(0.8))
                            )
                    }
                }

                Text(mode.description)
                    .font(AppTypography.body())
                    .foregroundColor(Color.appColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                supplementaryText(for: mode)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(cardBackground(for: mode))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.appColors.borderPrimary.opacity(0.25), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func supplementaryText(for mode: GameMode) -> some View {
        switch mode {
        case .timeAttack:
            if let limit = mode.timeLimit {
                Text("Timer: \(limit) seconds")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.accentPrimary)
            } else {
                EmptyView()
            }
        case .moveChallenge:
            if let limit = mode.defaultMoveLimit {
                Text("Moves available: \(limit)")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.accentPrimary)
            } else {
                EmptyView()
            }
        case .freePlay:
            Text("Endless cascades – no limits")
                .font(AppTypography.caption(weight: .medium))
                .foregroundColor(Color.appColors.accentPrimary)
        }
    }

    private func cardBackground(for mode: GameMode) -> LinearGradient {
        let colors: [Color] = { () -> [Color] in
            switch mode {
            case .freePlay:
                return [Color.appColors.surfaceSecondary.opacity(0.85), Color.appColors.surfacePrimary.opacity(0.85)]
            case .timeAttack:
                return [Color.appColors.accentSecondary.opacity(0.35), Color.appColors.surfacePrimary.opacity(0.85)]
            case .moveChallenge:
                return [Color.appColors.accentPrimary.opacity(0.25), Color.appColors.surfacePrimary.opacity(0.85)]
            }
        }()

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
