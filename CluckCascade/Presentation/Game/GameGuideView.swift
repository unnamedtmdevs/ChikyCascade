import SwiftUI

struct GameGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.animationsEnabled) private var animationsEnabled

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfaceSecondary]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        headerIcon
                        guideSections
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    .padding(.bottom, AppSpacing.xl)
                    .maxContentWidth(500)
                }
            }
            .navigationTitle("How to Play")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color.appColors.accentPrimary)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appColors.accentPrimary, Color.appColors.accentSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.appColors.borderEmphasis, lineWidth: 3)
                )

            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.top, AppSpacing.md)
    }

    private var guideSections: some View {
        VStack(spacing: AppSpacing.lg) {
            basicInstructionsSection
            stepByStepSection
            tipsSection
        }
    }

    private var basicInstructionsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Basic Rules",
                icon: "gamecontroller.fill"
            )

            InstructionCard(
                number: 1,
                title: "Select a Tile",
                description: "Tap any tile on the game board to select it. The selected tile will be highlighted with a thicker border."
            )

            InstructionCard(
                number: 2,
                title: "Swap with Adjacent Tile",
                description: "Tap a tile that is directly next to the selected one (up, down, left, or right - not diagonal) to swap them."
            )

            InstructionCard(
                number: 3,
                title: "Create Matches",
                description: "The swap only completes if it creates matches (3 or more of the same tile type in a row). If no matches are created, the swap is rejected."
            )
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.4), lineWidth: 2)
                )
        )
    }

    private var stepByStepSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Step by Step",
                icon: "list.number"
            )

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                StepItem(
                    step: "1",
                    text: "Look at the game board - you'll see a 6x6 grid of tiles"
                )
                StepItem(
                    step: "2",
                    text: "Tap any tile to select it (it will highlight)"
                )
                StepItem(
                    step: "3",
                    text: "Tap an adjacent tile (not diagonal) to swap"
                )
                StepItem(
                    step: "4",
                    text: "If matches are created, tiles clear and new ones fall"
                )
                StepItem(
                    step: "5",
                    text: "Chain reactions create cascades for bonus points!"
                )
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.4), lineWidth: 2)
                )
        )
    }

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(
                title: "Tips & Tricks",
                icon: "lightbulb.fill"
            )

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                TipItem(
                    icon: "arrow.triangle.2.circlepath",
                    text: "Plan your moves - think about potential cascades"
                )
                TipItem(
                    icon: "bolt.fill",
                    text: "Fill the Coop Power meter to unleash special powers"
                )
                TipItem(
                    icon: "sparkles",
                    text: "Use boosts strategically to clear difficult patterns"
                )
                TipItem(
                    icon: "target",
                    text: "Try different tile combinations if one doesn't work"
                )
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.4), lineWidth: 2)
                )
        )
    }
}

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.appColors.accentPrimary)

            Text(title)
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)
        }
    }
}

private struct InstructionCard: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.appColors.accentPrimary)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)

                Text(description)
                    .font(AppTypography.caption())
                    .foregroundColor(Color.appColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct StepItem: View {
    let step: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Text(step)
                .font(AppTypography.body(weight: .bold))
                .foregroundColor(Color.appColors.accentPrimary)
                .frame(width: 24, alignment: .leading)

            Text(text)
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct TipItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.appColors.accentSecondary)
                .frame(width: 24, alignment: .leading)

            Text(text)
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

