import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var boostsService: BoostsService
    @EnvironmentObject private var gameService: GameService
    @EnvironmentObject private var settingsStore: SettingsStore
    @EnvironmentObject private var progressStore: ProgressStore
    @Environment(\.dismiss) private var dismiss

    @State private var alert: ShopAlert?

    var compactPresentation: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.appColors.backgroundPrimary, Color.appColors.surfaceSecondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            FallingChickensBackground(density: 6, sizeRange: 34...48, speedRange: 16...28, opacity: 0.33)

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    header
                    featherBalance
                    productGrid
                    usageHistorySection
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.xl)
                .padding(.bottom, 120)
                .maxContentWidth()
            }
            .padding(.bottom, 70)
        }
        .keyboardDismissable()
        .navigationTitle(compactPresentation ? "Shop" : "Coop Shop")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $alert) { alert in
            Alert(title: Text(alert.message))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Coop Supply Shop")
                .font(AppTypography.display())
                .foregroundColor(Color.appColors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            Text("Exchange feathers for boosts to keep cascades flowing and progress faster.")
                .font(AppTypography.body())
                .foregroundColor(Color.appColors.textSecondary)
        }
    }

    private var featherBalance: some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Feather Balance")
                        .font(AppTypography.caption(weight: .medium))
                        .foregroundColor(Color.appColors.textSecondary)
                    Text("\(progressStore.progress.totalFeathers) feathers")
                        .font(AppTypography.headline(weight: .semibold))
                        .foregroundColor(Color.appColors.textPrimary)
                }
            } icon: {
                Text("🥚")
                    .font(.system(size: 24))
                    .padding(AppSpacing.sm)
                    .background(
                        Circle().fill(Color.appColors.surfacePrimary.opacity(0.65))
                    )
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appColors.surfaceSecondary.opacity(0.9))
        )
    }

    private var productGrid: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Boosts for Purchase")
                .font(AppTypography.headline(weight: .semibold))
                .foregroundColor(Color.appColors.textPrimary)

            VStack(spacing: AppSpacing.md) {
                ForEach(BoostType.allCases, id: \.self) { type in
                    productRow(for: type)
                }
            }
        }
    }

    private func productRow(for type: BoostType) -> some View {
        let cost = boostsService.price(for: type)
        let owned = availableCount(for: type)
        let canBuy = boostsService.canPurchase(type, feathers: progressStore.progress.totalFeathers)

        return VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.appColors.surfaceSecondary.opacity(0.6))
                        .frame(width: 54, height: 54)

                    Image(systemName: type.iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(Color.appColors.accentPrimary)
                }

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(type.title)
                        .font(AppTypography.headline(weight: .semibold))
                        .foregroundColor(Color.appColors.textPrimary)

                    Text(type.description)
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text("x\(owned)")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.textPrimary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs / 1.5)
                    .background(
                        Capsule().fill(Color.appColors.surfacePrimary.opacity(0.6))
                    )
            }

            HStack(spacing: AppSpacing.md) {
                Button {
                    purchase(type)
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "cart.fill")
                        Text("Buy")
                            .fixedSize(horizontal: true, vertical: false)
                            .layoutPriority(1)
                    }
                    .font(AppTypography.body(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                }
                .buttonStyle(WoodButtonStyle(variant: .primary))
                .disabled(!canBuy)
                .opacity(canBuy ? 1 : 0.45)

                Spacer()

                Text("\(cost) feathers")
                    .font(AppTypography.caption(weight: .medium))
                    .foregroundColor(Color.appColors.textPrimary)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        Capsule().fill(Color.appColors.surfacePrimary.opacity(0.7))
                    )
            }
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appColors.surfacePrimary.opacity(0.95),
                            Color.appColors.surfaceSecondary.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.appColors.borderPrimary.opacity(0.25), lineWidth: 1.5)
                )
        )
        .shadow(color: Color.appColors.accentPrimary.opacity(0.08), radius: 12, x: 0, y: 8)
    }

    private var usageHistorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Boost History")
                    .font(AppTypography.headline(weight: .semibold))
                    .foregroundColor(Color.appColors.textPrimary)
                Spacer()
                if let session = gameService.session {
                    Text("Level: \(session.level.title)")
                        .font(AppTypography.caption(weight: .medium))
                        .foregroundColor(Color.appColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }

            if boostsService.usageHistory.isEmpty {
                Text("No activity yet. Try purchasing a boost or triggering one in-game.")
                    .font(AppTypography.caption())
                    .foregroundColor(Color.appColors.textSecondary)
            } else {
                ForEach(boostsService.usageHistory.prefix(10)) { entry in
                    historyRow(entry)
                }
            }
        }
    }

    private func historyRow(_ entry: BoostUsage) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: entry.type.iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color.appColors.accentPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(entry.type.title)
                    .font(AppTypography.body(weight: .medium))
                    .foregroundColor(Color.appColors.textPrimary)
                Text(entry.context)
                    .font(AppTypography.caption())
                    .foregroundColor(Color.appColors.textSecondary)
                Text(entry.date, style: .date)
                    .font(AppTypography.caption(weight: .light))
                    .foregroundColor(Color.appColors.textTertiary)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xs)
    }

    private func availableCount(for type: BoostType) -> Int {
        boostsService.boosts.first(where: { $0.type == type })?.availableCount ?? 0
    }

    private func purchase(_ type: BoostType) {
        settingsStore.playTapFeedback()
        let cost = boostsService.price(for: type)

        guard cost > 0 else {
            alert = ShopAlert(message: "Purchase temporarily unavailable.")
            return
        }

        guard boostsService.canPurchase(type, feathers: progressStore.progress.totalFeathers) else {
            alert = ShopAlert(message: "Not enough feathers or storage is full.")
            return
        }

        guard gameService.spendFeathers(cost) else {
            alert = ShopAlert(message: "Not enough feathers.")
            return
        }

        guard boostsService.addBoost(type) else {
            alert = ShopAlert(message: "Storage limit reached for this boost type.")
            gameService.refundFeathers(cost)
            return
        }

        boostsService.recordUsage(of: type, context: "Purchased in shop for \(cost) feathers")

        if compactPresentation {
            dismiss()
        }
    }
}

private struct ShopAlert: Identifiable {
    let id = UUID()
    let message: String
}
