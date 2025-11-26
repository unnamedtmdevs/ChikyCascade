import SwiftUI

struct ProgressScreen: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var gameService: GameService
    @EnvironmentObject private var settingsStore: SettingsStore

    private var stats: PlayerProgress { progressStore.progress }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            FallingChickensBackground(density: 6, sizeRange: 34...48, speedRange: 16...28, opacity: 0.35)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    summaryCards
                    modePerformanceSection
                averagesSection
                    leaderboardSection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 120)
                .maxContentWidth()
            }
            .padding(.bottom, 70)
        }
        .keyboardDismissable()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Progress Ledger")
                .font(AppTypography.display())
                .foregroundColor(Color.appColors.textPrimary)
            Text("Track feathers, cascades, and coop milestones across your adventure.")
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
        }
    }

    private var summaryCards: some View {
        VStack(spacing: AppSpacing.md) {
            summaryCard(
                title: "Total Feathers",
                value: formatNumber(stats.totalFeathers),
                icon: "leaf.fill",
                subtitle: "Across all completed puzzles"
            )
            summaryCard(
                title: "Longest Combo",
                value: "\(stats.longestCombo)x",
                icon: "arrow.triangle.2.circlepath",
                subtitle: "Highest cascade achieved"
            )
            summaryCard(
                title: "Deepest Cascade",
                value: "\(stats.deepestCascade)",
                icon: "waveform.path.ecg",
                subtitle: "Max cascade depth so far"
            )
            summaryCard(
                title: "Daily Streak",
                value: "\(stats.dailyStreak) days",
                icon: "calendar",
                subtitle: "Consecutive coop visits"
            )
        }
    }

    private func summaryCard(title: String, value: String, icon: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.appColors.accentPrimary)
            Text(title)
                .font(AppTypography.body(weight: .medium))
                .foregroundColor(Color.appColors.textSecondary)
            Text(value)
                .font(AppTypography.title())
                .foregroundColor(Color.appColors.textPrimary)
            Text(subtitle)
                .font(AppTypography.caption())
                .foregroundColor(Color.appColors.textSecondary)
            Spacer()
        }
        .padding(AppSpacing.lg)
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.9))
        )
    }

    private var modePerformanceSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Mode Performance")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(spacing: AppSpacing.md) {
                ForEach(modePerformanceSummaries) { summary in
                    modePerformanceRow(for: summary)
                }
            }
        }
    }

    private var averagesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Play Patterns")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            averageMovesChart
            favoriteTileRow
            streakRow
        }
    }

    private var averageMovesChart: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Average Moves per Win")
                .font(AppTypography.body(weight: .medium))
                .foregroundColor(Color.appColors.textSecondary)

            GeometryReader { geometry in
                let width = geometry.size.width
                let data = averageMovesData()
                HStack(alignment: .bottom, spacing: AppSpacing.md) {
                    ForEach(data, id: \.label) { entry in
                        VStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appColors.accentSecondary)
                                .frame(width: 32, height: max(12, CGFloat(entry.value) * 6))
                            Text(entry.label)
                                .font(AppTypography.caption(weight: .medium))
                                .foregroundColor(Color.appColors.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
                .frame(width: width)
            }
            .frame(height: 160)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appColors.surfaceSecondary.opacity(0.9))
        )
    }

    private func averageMovesData() -> [(label: String, value: Double)] {
        let completions = progressStore.progress.completedLevels
        let grouped = Dictionary(grouping: completions) { levelIndex in
            levelIndex.levelID
        }
        let values = grouped.values.map { completed -> Double in
            let movesRemaining = completed.map { Double($0.bestMovesRemaining) }
            let total = movesRemaining.reduce(0, +)
            let avg = total / Double(max(1, movesRemaining.count))
            return Double(gameService.levelsCatalogue.first { $0.id == completed.first?.levelID }?.moveLimit ?? 20) - avg
        }
        if values.isEmpty {
            return [("Cozy", 14), ("Roost", 13), ("Flock", 12), ("Frenzy", 11)]
        }
        return zip(["Cozy", "Roost", "Flock", "Frenzy"], values.suffix(4)).map { ($0.0, $0.1) }
    }

    private var favoriteTileRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Favorite Tile Types")
                .font(AppTypography.body(weight: .medium))
                .foregroundColor(Color.appColors.textSecondary)

            HStack(spacing: AppSpacing.md) {
                ForEach(favoriteTiles(), id: \.kind) { item in
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: item.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.appColors.accentPrimary)
                        Text(item.title)
                            .font(AppTypography.caption(weight: .medium))
                            .foregroundColor(Color.appColors.textPrimary)
                        Text("\(Int(item.percentage * 100))%")
                            .font(AppTypography.caption(weight: .light))
                            .foregroundColor(Color.appColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.appColors.surfacePrimary.opacity(0.9))
                    )
                }
            }
        }
    }

    private func favoriteTiles() -> [(kind: CoopTileKind, title: String, icon: String, percentage: Double)] {
        let completions = progressStore.progress.completedLevels
        guard !completions.isEmpty else {
            return [
                (.egg, "Egg", "egg", 0.33),
                (.nest, "Nest", "bird", 0.27),
                (.corn, "Corn", "leaf", 0.22)
            ]
        }
        let kinds: [CoopTileKind] = [.egg, .nest, .corn, .broodyHen, .goldenEgg, .featherFan]
        let counts = kinds.map { kind -> Double in
            Double(completions.filter { $0.bestScore > 0 }.count) * (kind == .goldenEgg ? 0.15 : 0.2)
        }
        let total = counts.reduce(0, +)
        return Array(zip(kinds, counts)).prefix(3).map { pair in
            (pair.0, title(for: pair.0), icon(for: pair.0), total == 0 ? 0 : pair.1 / total)
        }
    }

    private func title(for kind: CoopTileKind) -> String {
        switch kind {
        case .egg: return "Egg"
        case .nest: return "Nest"
        case .corn: return "Corn"
        case .broodyHen: return "Broody"
        case .goldenEgg: return "Golden"
        case .featherFan: return "Feather"
        }
    }

    private func icon(for kind: CoopTileKind) -> String {
        switch kind {
        case .egg: return "egg"
        case .nest: return "bird"
        case .corn: return "leaf"
        case .broodyHen: return "flame"
        case .goldenEgg: return "sun.max"
        case .featherFan: return "wind"
        }
    }

    private var streakRow: some View {
        VStack {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Daily Streak")
                        .font(AppTypography.body(weight: .medium))
                        .foregroundColor(Color.appColors.textPrimary)
                    Text("Maintain a streak to earn bonus hints and feathers.")
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                }

                Spacer()

                Text("\(stats.dailyStreak) days")
                    .font(AppTypography.headline(weight: .semibold))
                    .foregroundColor(Color.appColors.accentPrimary)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        Capsule().fill(Color.appColors.surfaceSecondary.opacity(0.8))
                    )
            }
            Spacer()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.9))
        )
    }


    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Local Leaderboard")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            let topScores = progressStore.progress.completedLevels.sorted { $0.bestScore > $1.bestScore }.prefix(5)
            if topScores.isEmpty {
                Text("Complete puzzles to populate your leaderboard.")
                    .font(AppTypography.caption())
                    .foregroundColor(Color.appColors.textSecondary)
                    .frame(height: cardHeight, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.appColors.surfacePrimary.opacity(0.9))
                    )
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(Array(topScores.enumerated()), id: \.offset) { index, entry in
                        HStack(spacing: AppSpacing.md) {
                            Text("#\(index + 1)")
                                .font(AppTypography.headline(weight: .bold))
                                .foregroundColor(Color.appColors.accentPrimary)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                let levelTitle = gameService.levelsCatalogue.first(where: { $0.id == entry.levelID })?.title
                                    ?? GameMode.playOptions.first(where: { $0.persistenceID == entry.levelID })?.displayName
                                    ?? "Arcade Run"
                                let mode = GameMode.playOptions.first(where: { $0.persistenceID == entry.levelID })
                                let detail = mode.map { mode in
                                    mode.consumesMoves
                                        ? "Moves left: \(entry.bestMovesRemaining)"
                                        : "Feathers: \(entry.bestFeatherCount)"
                                } ?? "Moves left: \(entry.bestMovesRemaining)"
                                Text(levelTitle)
                                    .font(AppTypography.body(weight: .medium))
                                    .foregroundColor(Color.appColors.textPrimary)

                                Text("Score: \(entry.bestScore) • \(detail)")
                                    .font(AppTypography.caption())
                                    .foregroundColor(Color.appColors.textSecondary)
                            }
                            Spacer()
                            Text(entry.completionDate, style: .date)
                                .font(AppTypography.caption())
                                .foregroundColor(Color.appColors.textTertiary)
                        }
                        .padding(.vertical, AppSpacing.xs)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
                .frame(maxWidth: .infinity)
                .frame(minHeight: cardHeight)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.appColors.surfacePrimary.opacity(0.9))
                )
            }
        }
    }

    private var summaryColumns: [GridItem] {
        [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)]
    }

    private var cardHeight: CGFloat { 160 }

    private func formatNumber(_ value: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }

    private func modePerformanceRow(for summary: ModePerformanceSummary) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.appColors.surfaceSecondary.opacity(0.6))
                        .frame(width: 52, height: 52)
                    Image(systemName: summary.mode.iconName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.appColors.accentPrimary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text(summary.mode.displayName)
                            .font(AppTypography.body(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                        Spacer()
                        Text(summary.hasData ? formatNumber(summary.bestScore) : "—")
                            .font(AppTypography.title(weight: .semibold))
                            .foregroundColor(Color.appColors.textPrimary)
                    }

                    Text(summary.mode.sessionTagline)
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                        .lineLimit(2)

                    HStack(spacing: AppSpacing.md) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(summary.secondaryLabel)
                                .font(AppTypography.caption(weight: .medium))
                                .foregroundColor(Color.appColors.textSecondary)
                            Text(summary.secondaryValue)
                                .font(AppTypography.body(weight: .medium))
                                .foregroundColor(Color.appColors.textPrimary)
                        }

                        Divider()
                            .frame(height: 32)
                            .background(Color.appColors.surfaceSecondary.opacity(0.5))

                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text("Sessions")
                                .font(AppTypography.caption(weight: .medium))
                                .foregroundColor(Color.appColors.textSecondary)
                            Text("\(summary.sessionsPlayed)")
                                .font(AppTypography.body(weight: .medium))
                                .foregroundColor(Color.appColors.textPrimary)
                        }

                        Spacer()

                        if let lastPlayed = summary.lastPlayed {
                            VStack(alignment: .trailing, spacing: AppSpacing.xs) {
                                Text("Last played")
                                    .font(AppTypography.caption(weight: .medium))
                                    .foregroundColor(Color.appColors.textSecondary)
                                Text(lastPlayed, style: .date)
                                    .font(AppTypography.caption(weight: .medium))
                                    .foregroundColor(Color.appColors.textSecondary)
                            }
                        } else {
                            Text("Not played yet")
                                .font(AppTypography.caption())
                                .foregroundColor(Color.appColors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.9))
        )
        .shadow(color: Color.appColors.accentPrimary.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    private var modePerformanceSummaries: [ModePerformanceSummary] {
        GameMode.playOptions.map { mode in
            let completions = progressStore.progress.completedLevels.filter { $0.levelID == mode.persistenceID }
            let bestScore = completions.map(\.bestScore).max() ?? 0
            let bestFeathers = completions.map(\.bestFeatherCount).max() ?? 0
            let bestMovesRemaining = completions.map(\.bestMovesRemaining).max() ?? 0
            let lastPlayed = completions.map(\.completionDate).max()
            let sessions = completions.count
            return ModePerformanceSummary(
                mode: mode,
                bestScore: bestScore,
                bestFeathers: bestFeathers,
                bestMovesRemaining: bestMovesRemaining,
                sessionsPlayed: sessions,
                lastPlayed: lastPlayed
            )
        }
    }
}

private struct ModePerformanceSummary: Identifiable {
    let mode: GameMode
    let bestScore: Int
    let bestFeathers: Int
    let bestMovesRemaining: Int
    let sessionsPlayed: Int
    let lastPlayed: Date?

    var id: String { mode.id }

    var hasData: Bool {
        sessionsPlayed > 0 && (bestScore > 0 || bestFeathers > 0 || bestMovesRemaining > 0)
    }

    private func formatted(_ value: Int) -> String {
        NumberFormatter.localizedString(from: NSNumber(value: value), number: .decimal)
    }

    var secondaryLabel: String {
        switch mode {
        case .moveChallenge:
            return "Best moves left"
        case .timeAttack:
            return "Best feather haul"
        case .freePlay:
            return "Longest feather run"
        }
    }

    var secondaryValue: String {
        switch mode {
        case .moveChallenge:
            return hasData ? formatted(bestMovesRemaining) : "—"
        default:
            return hasData ? formatted(bestFeathers) : "—"
        }
    }
}



