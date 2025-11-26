import SwiftUI

struct CustomTabBarView: View {
    @Environment(\.animationsEnabled) private var animationsEnabled
    let tabs: [AppTab]
    @Binding var selection: AppTab
    let onSelection: (AppTab) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ForEach(tabs) { tab in
                Button {
                    selection = tab
                    onSelection(tab)
                } label: {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: .medium))
                            .scaleEffect(selection == tab && animationsEnabled ? 1.1 : 1.0)
                            .foregroundColor(selection == tab ? Color.appColors.accentPrimary : Color.appColors.textSecondary)
                            .accessibilityHidden(true)

                        Text(tab.title)
                            .font(AppTypography.caption(weight: .medium))
                            .foregroundColor(selection == tab ? Color.appColors.textPrimary : Color.appColors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.vertical, AppSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selection == tab ? Color.appColors.surfaceSecondary.opacity(0.8) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
                .frame(minHeight: 48)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.lg)
        .ignoresSafeArea(edges: .bottom)
    }
}

