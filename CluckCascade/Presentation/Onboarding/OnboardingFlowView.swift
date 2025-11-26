import SwiftUI

struct OnboardingFlowView: View {
    struct Page: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let detail: String
    }

    private let pages: [Page] = [
        Page(
            title: "Welcome to the Coop",
            subtitle: "Swap hens, eggs, and straw for vibrant cascades",
            icon: "rosette",
            detail: "Strategize each move to spark chain reactions and gather feathers for your flock."
        ),
        Page(
            title: "Learn the Ropes",
            subtitle: "Slide adjacent tiles to stir lively cascades",
            icon: "square.grid.3x3.fill",
            detail: "Fuel coop powers, clear objectives, and uncover handcrafted farmhouse scenes as each puzzle unfolds."
        ),
        Page(
            title: "Ready to Play",
            subtitle: "Embark on cozy coop puzzles",
            icon: "sparkles",
            detail: "Unlock new twists every ten puzzles, earn feathers, and celebrate your achievements in the barn ledger."
        )
    ]

    let onComplete: () -> Void

    @Environment(\.animationsEnabled) private var animationsEnabled
    @State private var currentIndex: Int = 0

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                Spacer(minLength: 0)

                TabView(selection: $currentIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .padding(.horizontal, AppSpacing.xl)
                            .maxContentWidth()
                            .tag(index)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Onboarding step \(index + 1) of \(pages.count)")
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(animationsEnabled ? .easeInOut : nil, value: currentIndex)

                HStack(spacing: AppSpacing.sm) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentIndex ? Color.appColors.accentPrimary : Color.appColors.surfaceTertiary)
                            .frame(width: index == currentIndex ? 36 : 12, height: 8)
                            .animation(animationsEnabled ? .spring(response: 0.4, dampingFraction: 0.8) : nil, value: currentIndex)
                            .accessibilityHidden(true)
                    }
                }

                OnboardingControls(
                    isLast: currentIndex == pages.count - 1,
                    onPrimary: advance,
                    onSecondary: skip
                )
                .padding(.horizontal, AppSpacing.xl)
                .maxContentWidth()

                Spacer(minLength: 0)
            }
            .padding(.vertical, AppSpacing.xxl)
        }
        .keyboardDismissable()
    }

    private func advance() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        } else {
            onComplete()
        }
    }

    private func skip() {
        onComplete()
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingFlowView.Page

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .medium))
                .foregroundStyle(Color.appColors.accentPrimary, Color.appColors.accentSecondary)
                .padding(AppSpacing.lg)
                .background(
                    Circle()
                        .fill(Color.appColors.surfaceSecondary.opacity(0.6))
                        .overlay(
                            Circle()
                                .stroke(Color.appColors.borderEmphasis.opacity(0.4), lineWidth: 2)
                        )
                )

            VStack(spacing: AppSpacing.sm) {
                Text(page.title)
                    .font(AppTypography.title())
                    .foregroundColor(Color.appColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Text(page.subtitle)
                    .font(AppTypography.headline())
                    .foregroundColor(Color.appColors.accentPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
            }

            Text(page.detail)
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
                .lineLimit(5)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.4), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 12)
        )
        .accessibilityElement(children: .combine)
    }
}

private struct OnboardingControls: View {
    let isLast: Bool
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: onSecondary) {
                Text("Skip")
                    .font(AppTypography.body(weight: .medium))
                    .foregroundColor(Color.appColors.textSecondary)
                    .padding(.vertical, AppSpacing.sm)
                    .padding(.horizontal, AppSpacing.xl)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appColors.borderPrimary.opacity(0.5), lineWidth: 2)
                    )
            }
            .accessibilityLabel("Skip onboarding")

            Button(action: onPrimary) {
                Text(isLast ? "Start Playing" : "Continue")
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
                    .padding(.vertical, AppSpacing.sm)
                    .padding(.horizontal, AppSpacing.xl)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appColors.accentPrimary, Color.appColors.accentSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.appColors.borderEmphasis, lineWidth: 2)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 8)
            }
            .accessibilityLabel(isLast ? "Begin playing" : "Continue onboarding")
        }
    }
}



