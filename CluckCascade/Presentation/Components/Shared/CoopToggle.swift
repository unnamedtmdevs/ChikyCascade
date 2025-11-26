import SwiftUI

struct CoopToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            isOn.toggle()
            action?()
        } label: {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(title)
                        .font(AppTypography.body(weight: .semibold))
                        .foregroundColor(Color.appColors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(AppTypography.caption())
                        .foregroundColor(Color.appColors.textSecondary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isOn ? Color.appColors.accentPrimary : Color.appColors.surfaceSecondary)
                    .frame(width: 56, height: 32)
                    .overlay(alignment: isOn ? .trailing : .leading) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .padding(4)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.appColors.borderPrimary.opacity(0.4), lineWidth: 2)
                    )
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.appColors.surfacePrimary.opacity(0.9))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}



