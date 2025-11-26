import SwiftUI

struct GameBoardTileView: View {
    let tile: CoopTile
    let isSelected: Bool
    let isClearing: Bool
    let size: CGFloat

    @Environment(\.animationsEnabled) private var animationsEnabled
    @State private var burstProgress: Bool = false
    @State private var vanishProgress: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundColor(for: tile.kind))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(borderColor(for: tile.kind), lineWidth: isSelected ? 4 : 2)
                )

            if let symbol = symbolName(for: tile.kind) {
                Image(systemName: symbol)
                    .font(.system(size: max(20, size * 0.45), weight: .semibold))
                    .foregroundStyle(iconGradient(for: tile.kind))
            } else if let emoji = emoji(for: tile.kind) {
                Text(emoji)
                    .font(.system(size: max(20, size * 0.45), weight: .semibold))
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(vanishProgress ? 0.35 : 1)
        .opacity(vanishProgress ? 0 : 1)
        .overlay(
            Circle()
                .stroke(Color.glowYellow.opacity(isClearing ? 0.85 : 0), lineWidth: 4)
                .scaleEffect(isClearing ? (burstProgress ? 1.35 : 0.55) : 0.6)
                .opacity(isClearing ? (burstProgress ? 0 : 0.75) : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.appColors.borderPrimary.opacity(isSelected ? 0.8 : 0.4), lineWidth: isSelected ? 4 : 0)
        )
        .animation(animationsEnabled ? .spring(response: 0.45, dampingFraction: 0.85) : nil, value: tile.position)
        .animation(animationsEnabled ? .easeInOut(duration: 0.22) : nil, value: vanishProgress)
        .onChange(of: isClearing) { newValue in
            guard animationsEnabled else { return }
            if newValue {
                runClearAnimation()
            } else {
                resetAnimations()
            }
        }
        .onAppear {
            guard animationsEnabled else { return }
            if isClearing {
                runClearAnimation()
            } else {
                resetAnimations()
            }
        }
    }

    private func runClearAnimation() {
        burstProgress = false
        vanishProgress = false

        withAnimation(.easeOut(duration: 0.28)) {
            burstProgress = true
        }
        withAnimation(.easeIn(duration: 0.2)) {
            vanishProgress = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            resetAnimations()
        }
    }

    private func resetAnimations() {
        burstProgress = false
        vanishProgress = false
    }

    private func backgroundColor(for kind: CoopTileKind) -> Color {
        switch kind {
        case .egg: return Color.appColors.surfacePrimary
        case .nest: return Color.appColors.surfaceSecondary
        case .corn: return Color(red: 0.75, green: 0.47, blue: 0.22)
        case .broodyHen: return Color(red: 0.47, green: 0.29, blue: 0.24)
        case .goldenEgg: return Color(red: 0.92, green: 0.78, blue: 0.35)
        case .featherFan: return Color(red: 0.62, green: 0.74, blue: 0.86)
        }
    }

    private func borderColor(for kind: CoopTileKind) -> Color {
        switch kind {
        case .egg: return Color.appColors.borderPrimary
        case .nest: return Color.appColors.borderEmphasis
        case .corn: return Color(red: 0.55, green: 0.33, blue: 0.18)
        case .broodyHen: return Color(red: 0.72, green: 0.42, blue: 0.33)
        case .goldenEgg: return Color(red: 0.96, green: 0.85, blue: 0.54)
        case .featherFan: return Color(red: 0.48, green: 0.64, blue: 0.78)
        }
    }

    private func symbolName(for kind: CoopTileKind) -> String? {
        switch kind {
        case .egg: return nil
        case .nest: return nil
        case .corn: return "leaf"
        case .broodyHen: return "flame"
        case .goldenEgg: return "sun.max"
        case .featherFan: return "wind"
        }
    }

    private func emoji(for kind: CoopTileKind) -> String? {
        switch kind {
        case .egg: return "🥚"
        case .nest: return "🐔"
        default: return nil
        }
    }

    private func iconGradient(for kind: CoopTileKind) -> LinearGradient {
        switch kind {
        case .egg:
            return LinearGradient(colors: [Color.white, Color.appColors.textSecondary], startPoint: .top, endPoint: .bottom)
        case .nest:
            return LinearGradient(colors: [Color(red: 0.84, green: 0.68, blue: 0.46), Color(red: 0.64, green: 0.50, blue: 0.31)], startPoint: .top, endPoint: .bottom)
        case .corn:
            return LinearGradient(colors: [Color(red: 0.96, green: 0.83, blue: 0.41), Color(red: 0.71, green: 0.47, blue: 0.17)], startPoint: .top, endPoint: .bottom)
        case .broodyHen:
            return LinearGradient(colors: [Color(red: 0.93, green: 0.59, blue: 0.47), Color(red: 0.61, green: 0.34, blue: 0.29)], startPoint: .top, endPoint: .bottom)
        case .goldenEgg:
            return LinearGradient(colors: [Color(red: 0.98, green: 0.88, blue: 0.55), Color(red: 0.86, green: 0.69, blue: 0.28)], startPoint: .top, endPoint: .bottom)
        case .featherFan:
            return LinearGradient(colors: [Color(red: 0.69, green: 0.83, blue: 0.98), Color(red: 0.41, green: 0.61, blue: 0.89)], startPoint: .top, endPoint: .bottom)
        }
    }
}
