import SwiftUI

struct MedalsView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var settingsStore: SettingsStore

    private enum StatusFilter: String, CaseIterable, Identifiable {
        case all
        case unlocked
        case locked

        var id: String { rawValue }

        var title: String {
            switch self {
            case .all: return "All"
            case .unlocked: return "Unlocked"
            case .locked: return "Locked"
            }
        }
    }

    private let categories: [Achievement.Category] = [.progression, .skill, .collection, .streak]

    @State private var selectedCategory: Achievement.Category? = nil
    @State private var statusFilter: StatusFilter = .all

    private var achievements: [Achievement] {
        if !progressStore.achievements.isEmpty {
            return progressStore.achievements
        }
        return [
            Achievement(title: "Feather Collector", description: "Earn 1,000 feathers across puzzles.", category: .collection, iconName: "leaf.fill"),
            Achievement(title: "Cascade Maestro", description: "Trigger a five-step cascade in one puzzle.", category: .skill, iconName: "waveform.path.ecg"),
            Achievement(title: "Power Sage", description: "Unleash Coop Power ten times.", category: .progression, iconName: "bolt.circle"),
            Achievement(title: "Tempo Chaser", description: "Score 25,000 points in a Time Attack run.", category: .skill, iconName: "timer"),
            Achievement(title: "Move Maestro", description: "Reach 15,000 points in a Move Challenge session.", category: .progression, iconName: "target"),
            Achievement(title: "Streak Guardian", description: "Keep a seven-day streak alive.", category: .streak, iconName: "calendar"),
            Achievement(title: "Hint Whisperer", description: "Use coop hints twenty times to guide tricky cascades.", category: .progression, iconName: "lightbulb"),
            Achievement(title: "Combo Conductor", description: "Chain seven cascades in a single match.", category: .skill, iconName: "sparkles"),
            Achievement(title: "Feather Tycoon", description: "Accumulate 10,000 feathers across your career.", category: .collection, iconName: "coins"),
            Achievement(title: "Early Rooster", description: "Log in five mornings in a row before sunrise.", category: .streak, iconName: "sunrise"),
            Achievement(title: "Booster Baron", description: "Own at least fifteen boosts at once.", category: .collection, iconName: "shippingbox.fill"),
            Achievement(title: "Swift Talons", description: "Win a Time Attack round with 30 seconds left on the clock.", category: .skill, iconName: "hare.fill"),
            Achievement(title: "Golden Clutch", description: "Finish a puzzle with one move remaining and still earn three stars.", category: .progression, iconName: "star.circle"),
            Achievement(title: "Arcade Ace", description: "Reach wave 12 in Arcade mode without losing a life.", category: .skill, iconName: "arcade.stick.console"),
            Achievement(title: "Feather Forecast", description: "Earn 2,500 feathers in a single day.", category: .collection, iconName: "cloud.sun"),
            Achievement(title: "Strategist", description: "Complete ten puzzles in a row without using boosts.", category: .progression, iconName: "brain.head.profile"),
            Achievement(title: "Coop Curator", description: "Unlock every tile type entry in the compendium.", category: .collection, iconName: "books.vertical"),
            Achievement(title: "Rescue Hero", description: "Save 60 chicks across all rescue objectives.", category: .progression, iconName: "heart.circle"),
            Achievement(title: "Marathon Runner", description: "Play for three consecutive hours in a single day.", category: .streak, iconName: "figure.run"),
            Achievement(title: "Precision Picker", description: "Clear a board with zero missed moves.", category: .skill, iconName: "target.circle"),
            Achievement(title: "Daily Devotee", description: "Complete 30 daily challenges in a month.", category: .streak, iconName: "calendar.badge.clock"),
            Achievement(title: "Feather Philanthropist", description: "Gift 5,000 feathers to coop friends.", category: .collection, iconName: "gift.fill")
        ]
    }

    private var filteredAchievements: [Achievement] {
        achievements
            .filter { selectedCategory == nil || $0.category == selectedCategory }
            .filter { achievement in
                switch statusFilter {
                case .all: return true
                case .unlocked: return achievement.unlockedDate != nil
                case .locked: return achievement.unlockedDate == nil
                }
            }
            .sorted(by: sortAchievements(lhs:rhs:))
    }

    private var progressMetrics: (total: Int, unlocked: Int, completion: Double) {
        let total = achievements.count
        let unlocked = achievements.filter { $0.unlockedDate != nil }.count
        let completion = total == 0 ? 0 : Double(unlocked) / Double(total)
        return (total, unlocked, completion)
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfacePrimary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FallingChickensBackground(density: 5, sizeRange: 34...48, speedRange: 18...30, opacity: 0.32)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    progressSummary
                    filtersSection

                    if statusFilter != .locked,
                       selectedCategory == nil,
                       let latest = achievements.filter({ $0.unlockedDate != nil }).sorted(by: newestFirst(lhs:rhs:)).first {
                        spotlight(for: latest)
                    }

                    if filteredAchievements.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: AppSpacing.md, pinnedViews: []) {
                            ForEach(filteredAchievements) { achievement in
                                medalRow(for: achievement)
                            }
                        }
                    }
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
            Text("Medals")
                .font(AppTypography.display())
                .foregroundColor(Color.appColors.textPrimary)
            Text("Track every coop accolade you have earned and the legends still waiting to shine.")
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
        }
    }

    private var progressSummary: some View {
        let metrics = progressMetrics

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("\(metrics.unlocked)/\(metrics.total) unlocked")
                        .font(AppTypography.headline(weight: .semibold))
                        .foregroundColor(Color.appColors.textPrimary)
                    Text("Keep cascading to unlock more coop lore and rewards.")
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                }
                Spacer()
            }

            ProgressView(value: metrics.completion)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.appColors.accentPrimary))
                .frame(height: 6)
                .background(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(Color.appColors.surfaceSecondary.opacity(0.6))
                )
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

            Text(String(format: "%.0f%% complete", metrics.completion * 100))
                .font(AppTypography.caption(weight: .medium))
                .foregroundColor(Color.appColors.textSecondary)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.3), lineWidth: 2)
                )
        )
    }

    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Filters")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    filterChip(title: "All", isActive: selectedCategory == nil) {
                        selectedCategory = nil
                        settingsStore.playTapFeedback()
                    }
                    ForEach(categories, id: \.self) { category in
                        filterChip(title: categoryTitle(for: category), isActive: selectedCategory == category) {
                            selectedCategory = selectedCategory == category ? nil : category
                            settingsStore.playTapFeedback()
                        }
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }

            HStack(spacing: AppSpacing.sm) {
                ForEach(StatusFilter.allCases) { filter in
                    filterChip(title: filter.title, isActive: statusFilter == filter) {
                        statusFilter = filter
                        settingsStore.playTapFeedback()
                    }
                }
            }
        }
    }

    private func filterChip(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.caption(weight: .medium))
                .foregroundColor(isActive ? Color.appColors.textPrimary : Color.appColors.textSecondary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.xs)
                .background(
                    Capsule(style: .continuous)
                        .fill(isActive ? Color.appColors.accentSecondary.opacity(0.85) : Color.appColors.surfaceSecondary.opacity(0.6))
                )
        }
        .buttonStyle(.plain)
    }

    private func spotlight(for achievement: Achievement) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Latest Medal")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: achievement.iconName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.appColors.accentPrimary)
                    Spacer()
                    if let unlockedDate = achievement.unlockedDate {
                        Text(unlockedDate, style: .date)
                            .font(AppTypography.caption(weight: .medium))
                            .foregroundColor(Color.appColors.textSecondary)
                    }
                }

                Text(achievement.title)
                    .font(AppTypography.title(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)

                Text(achievement.description)
                    .font(AppTypography.body())
                    .foregroundColor(Color.appColors.textSecondary)
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.appColors.surfaceSecondary.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.appColors.borderPrimary.opacity(0.35), lineWidth: 2)
                    )
            )
        }
    }

    private func medalRow(for achievement: Achievement) -> some View {
        let isUnlocked = achievement.unlockedDate != nil

        return VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label(achievement.title, systemImage: achievement.iconName)
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(isUnlocked ? Color.appColors.textPrimary : Color.appColors.textSecondary)
                    .labelStyle(.titleAndIcon)
                Spacer()
                Image(systemName: isUnlocked ? "checkmark.seal.fill" : "lock")
                    .foregroundColor(isUnlocked ? Color.appColors.accentPrimary : Color.appColors.textTertiary)
            }

            Text(achievement.description)
                .font(AppTypography.caption())
                .foregroundColor(Color.appColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let date = achievement.unlockedDate {
                Text(date, style: .date)
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.textTertiary)
            }

            Divider()
                .background(Color.appColors.surfaceSecondary.opacity(0.6))
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(isUnlocked ? 0.95 : 0.65))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(isUnlocked ? 0.4 : 0.2), lineWidth: 1.5)
                )
        )
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "rosette")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color.appColors.accentPrimary)
                .padding()
                .background(
                    Circle()
                        .fill(Color.appColors.surfaceSecondary.opacity(0.7))
                )

            Text("No medals match your filters")
                .font(AppTypography.title(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            Text("Adjust the filters above or keep cascading to discover new accolades.")
                .font(AppTypography.caption())
                .foregroundColor(Color.appColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.appColors.surfacePrimary.opacity(0.9))
        )
    }

    private func newestFirst(lhs: Achievement, rhs: Achievement) -> Bool {
        guard let lhsDate = lhs.unlockedDate, let rhsDate = rhs.unlockedDate else { return lhs.unlockedDate != nil }
        return lhsDate > rhsDate
    }

    private func sortAchievements(lhs: Achievement, rhs: Achievement) -> Bool {
        switch (lhs.unlockedDate, rhs.unlockedDate) {
        case let (l?, r?):
            return l > r
        case (_?, nil):
            return true
        case (nil, _?):
            return false
        default:
            return lhs.title < rhs.title
        }
    }

    private func categoryTitle(for category: Achievement.Category) -> String {
        switch category {
        case .progression: return "Progression"
        case .skill: return "Skill"
        case .collection: return "Collection"
        case .streak: return "Streak"
        }
    }
}
