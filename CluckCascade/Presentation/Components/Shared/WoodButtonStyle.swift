import SwiftUI

struct WoodButtonStyle: ButtonStyle {
    enum Variant {
        case primary
        case secondary
        case destructive
    }

    let variant: Variant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.appColors.borderEmphasis.opacity(0.6), lineWidth: 2)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        let base: Color
        switch variant {
        case .primary:
            base = Color.appColors.accentPrimary
        case .secondary:
            base = Color.appColors.surfaceSecondary
        case .destructive:
            base = Color.appColors.danger
        }
        return isPressed ? base.opacity(0.8) : base
    }
}



