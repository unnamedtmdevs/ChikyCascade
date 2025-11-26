
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var gameService: GameService
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var boostsService: BoostsService

    @State private var isShowingGame = false
    @State private var showingModePicker = false

    @State private var highlightsPulse: Bool = false

    private let cardHeight: CGFloat = 150

    private struct ModeSummary: Identifiable {
        let mode: GameMode
        let bestScore: Int
        let bestFeathers: Int
        var id: String { mode.id }
    }

    private var bestScore: Int {
        progressStore.progress.completedLevels.map { $0.bestScore }.max() ?? 0
    }

    private var dailyStreak: Int {
        progressStore.progress.dailyStreak
    }

    private var statItems: [(title: String, value: String, icon: String)] {
        [
            ("Feathers", formatNumber(progressStore.progress.totalFeathers), "leaf.fill"),
            ("Best Score", formatNumber(bestScore), "waveform"),
            ("Streak", "\(dailyStreak)d", "flame")
        ]
    }

    private var modeSummaries: [ModeSummary] {
        GameMode.playOptions.map { mode in
            let completion = progressStore.progress.completedLevels.first { $0.levelID == mode.persistenceID }
            return ModeSummary(
                mode: mode,
                bestScore: completion?.bestScore ?? 0,
                bestFeathers: completion?.bestFeatherCount ?? 0
            )
        }
    }

    var body: some View {
        ZStack {
            NavigationLink("", isActive: $isShowingGame) {
                GameView()
                    .environmentObject(gameService)
                    .environmentObject(boostsService)
                    .environmentObject(settingsStore)
                    .environmentObject(progressStore)
            }
            .hidden()

            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfaceSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                FallingChickensBackground(density: 6, sizeRange: 36...50, speedRange: 18...30, opacity: 0.42)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {
                    heroBanner
                    statsSection
                    modeDigest
                    boostsSpotlight
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 140)
                .maxContentWidth()
            }
            .padding(.bottom, 70)
        }
        .keyboardDismissable()
        .sheet(isPresented: $showingModePicker) {
            ModeSelectionView(onSelect: launch)
                .environmentObject(gameService)
                .environmentObject(settingsStore)
                .environmentObject(progressStore)
                .environmentObject(boostsService)
        }
        .onAppear {
            highlightsPulse = true
        }
    }

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.appColors.surfacePrimary.opacity(0.95), Color.appColors.surfaceSecondary.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 140, weight: .light))
                    .foregroundStyle(Color.appColors.accentPrimary.opacity(0.25))
                    .offset(x: 120, y: -80),
                alignment: .topTrailing
            )

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Welcome to the Coop")
                    .font(AppTypography.display())
                    .foregroundColor(Color.appColors.textPrimary)
                    .multilineTextAlignment(.leading)

                Text("Pick a fresh cascade challenge or dive into a relaxed free session. Every mode grows your farmyard mastery.")
                    .font(AppTypography.body())
                    .foregroundColor(Color.appColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    Button(action: openModePicker) {
                        Label("Play", systemImage: "play.circle.fill")
                            .labelStyle(.titleAndIcon)
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                            .padding(.horizontal, AppSpacing.xl)
                            .padding(.vertical, AppSpacing.sm)
                    }
                    .buttonStyle(WoodButtonStyle(variant: .primary))
                    .scaleEffect(highlightsPulse ? 1.04 : 1.0)
                    .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: highlightsPulse)
                    Spacer()
                }
            }
            .padding(AppSpacing.xl)
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Highlights")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(Array(statItems.enumerated()), id: \.element.title) { index, item in
                    HStack(spacing: AppSpacing.md) {
                        Image(systemName: item.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.appColors.accentPrimary)
                            .frame(width: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(AppTypography.caption(weight: .medium))
                                .foregroundColor(Color.appColors.textSecondary)
                            Text(item.value)
                                .font(AppTypography.title(weight: .semibold))
                                .foregroundColor(Color.appColors.textPrimary)
                        }

                        Spacer()

                        Text(index.isMultiple(of: 2) ? "🐣" : "🐤")
                            .font(.system(size: 22))
                            .offset(y: highlightsPulse ? -4 : 4)
                            .rotationEffect(.degrees(highlightsPulse ? -6 : 6))
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: highlightsPulse)
                    }
                    .padding(.vertical, AppSpacing.xs)

                    if index < statItems.count - 1 {
                        Divider()
                            .overlay(Color.appColors.borderPrimary.opacity(0.2))
                    }
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.appColors.surfacePrimary.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.appColors.accentPrimary.opacity(0.08), lineWidth: 1.5)
                    )
                    .shadow(color: Color.appColors.accentPrimary.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
    }

    private var modeDigest: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Mode Highlights")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(spacing: AppSpacing.sm) {
                ForEach(modeSummaries) { summary in
                    HStack(spacing: AppSpacing.sm) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(summary.mode.displayName)
                                .font(AppTypography.body(weight: .semibold))
                                .foregroundColor(Color.appColors.textPrimary)
                            Text(summary.mode.sessionTagline)
                                .font(AppTypography.caption())
                                .foregroundColor(Color.appColors.textSecondary)
                                .lineLimit(2)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Best Score")
                                .font(AppTypography.caption(weight: .medium))
                                .foregroundColor(Color.appColors.textSecondary)
                            Text(formatNumber(summary.bestScore))
                                .font(AppTypography.title(weight: .semibold))
                                .foregroundColor(Color.appColors.textPrimary)
                            if summary.bestFeathers > 0 {
                                Text("\(formatNumber(summary.bestFeathers)) feathers")
                                    .font(AppTypography.caption(weight: .medium))
                                    .foregroundColor(Color.appColors.accentPrimary)
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                    .frame(minHeight: cardHeight, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.appColors.surfacePrimary.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.appColors.accentPrimary.opacity(0.08), lineWidth: 1)
                            )
                            .shadow(color: Color.appColors.accentPrimary.opacity(0.05), radius: 8, x: 0, y: 4)
                    )
                }
            }
        }
    }

    private var boostsSpotlight: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Label("Boost Inventory", systemImage: "sparkles")
                .labelStyle(.titleAndIcon)
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                if boostsService.boosts.isEmpty {
                    Text("No boosts available yet. Earn them during your runs!")
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                        .padding(.vertical, AppSpacing.xs)
                } else {
                    ForEach(Array(boostsService.boosts.enumerated()), id: \.element.id) { index, boost in
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: boost.type.iconName)
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(Color.appColors.accentPrimary)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(boost.type.title)
                                    .font(AppTypography.body(weight: .semibold))
                                    .foregroundColor(Color.appColors.textPrimary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .layoutPriority(1)
                                Text(boost.type.description)
                                    .font(AppTypography.caption())
                                    .foregroundColor(Color.appColors.textSecondary)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .layoutPriority(1)
                            }

                            Spacer()

                            Text("x\(boost.availableCount)")
                                .font(AppTypography.title(weight: .semibold))
                                .foregroundColor(Color.appColors.accentPrimary)

                            Text(index.isMultiple(of: 2) ? "🐥" : "🐣")
                                .font(.system(size: 24))
                                .offset(y: highlightsPulse ? -5 : 5)
                                .rotationEffect(.degrees(highlightsPulse ? -8 : 8))
                                .animation(.easeInOut(duration: 1.7).repeatForever(autoreverses: true), value: highlightsPulse)
                        }
                        .padding(.vertical, AppSpacing.xs)

                        if index < boostsService.boosts.count - 1 {
                            Divider()
                                .overlay(Color.appColors.borderPrimary.opacity(0.2))
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.appColors.surfaceSecondary.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.appColors.accentPrimary.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: Color.appColors.accentPrimary.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
    }

    private func openModePicker() {
        settingsStore.playTapFeedback()
        showingModePicker = true
    }

    private func launch(mode: GameMode) {
        showingModePicker = false
        gameService.startGame(mode: mode)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isShowingGame = true
        }
    }

    private func formatNumber(_ value: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }
}
