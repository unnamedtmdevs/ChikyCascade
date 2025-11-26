import SwiftUI

struct AppColorScheme {
    static let shared = AppColorScheme()

    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let surfacePrimary: Color
    let surfaceSecondary: Color
    let surfaceTertiary: Color
    let accentPrimary: Color
    let accentSecondary: Color
    let accentTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let borderPrimary: Color
    let borderEmphasis: Color
    let success: Color
    let warning: Color
    let danger: Color

    private init() {
        backgroundPrimary = .themeOneBackground
        backgroundSecondary = .themeTwoBackground
        surfacePrimary = .themeOneInterface
        surfaceSecondary = .themeTwoInterface
        surfaceTertiary = .themeThreeInterface
        accentPrimary = .highlightOrange
        accentSecondary = .accentGreen
        accentTertiary = .themeOneElementBlue
        textPrimary = .themeTwoText
        textSecondary = .themeOneText
        textTertiary = .themeThreeNeutral
        borderPrimary = .woodTone
        borderEmphasis = .shadowBlend
        success = .themeThreeSuccess
        warning = .glowYellow
        danger = .themeOneElementPink
    }
}

extension Color {
    static let appColors = AppColorScheme.shared
}
