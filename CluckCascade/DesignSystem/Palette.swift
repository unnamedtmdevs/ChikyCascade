import SwiftUI

extension Color {
    static let coreLight = Color(red: 245/255, green: 224/255, blue: 160/255)
    static let coreDark = Color(red: 74/255, green: 44/255, blue: 26/255)
    static let accentGreen = Color(red: 107/255, green: 175/255, blue: 74/255)
    static let highlightOrange = Color(red: 242/255, green: 140/255, blue: 56/255)
    static let deepShade = Color(red: 58/255, green: 111/255, blue: 42/255)
    static let woodTone = Color(red: 92/255, green: 64/255, blue: 51/255)
    static let shadowBlend = Color(red: 42/255, green: 74/255, blue: 42/255)
    static let baseSolid = Color(red: 26/255, green: 26/255, blue: 26/255)
    static let textBright = Color(red: 1, green: 1, blue: 1)
    static let actionGreen = Color(red: 0, green: 204/255, blue: 0)
    static let glowYellow = Color(red: 255/255, green: 215/255, blue: 0)

    static let themeOneBackground = Color(hex: "1C2F4E")
    static let themeOneGameArea = Color(hex: "505050")
    static let themeOneText = Color(hex: "E0E0E0")
    static let themeOneButton = Color(hex: "F57C00")
    static let themeOneSuccess = Color(hex: "2E7D32")
    static let themeOneObjectWhite = Color(hex: "F0F0F0")
    static let themeOneObjectYellow = Color(hex: "FFC107")
    static let themeOneObjectGreen = Color(hex: "388E3C")
    static let themeOneElementBlue = Color(hex: "4A90E2")
    static let themeOneElementPink = Color(hex: "FF4081")
    static let themeOneNeutral = Color(hex: "757575")
    static let themeOneInterface = Color(hex: "424242")

    static let themeTwoBackground = Color(hex: "1E3A5F")
    static let themeTwoGameArea = Color(hex: "4E4E4E")
    static let themeTwoText = Color(hex: "F5F5F5")
    static let themeTwoButton = Color(hex: "FF9800")
    static let themeTwoSuccess = Color(hex: "43A047")
    static let themeTwoObjectWhite = Color(hex: "FAFAFA")
    static let themeTwoObjectYellow = Color(hex: "FFCA28")
    static let themeTwoObjectGreen = Color(hex: "66BB6A")
    static let themeTwoElementBlue = Color(hex: "42A5F5")
    static let themeTwoElementPink = Color(hex: "EC407A")
    static let themeTwoNeutral = Color(hex: "7B7B7B")
    static let themeTwoInterface = Color(hex: "3C3C3C")

    static let themeThreeBackground = Color(hex: "2E4A6E")
    static let themeThreeGameArea = Color(hex: "616161")
    static let themeThreeText = Color(hex: "FFFFFF")
    static let themeThreeButton = Color(hex: "FFAB00")
    static let themeThreeSuccess = Color(hex: "4CAF50")
    static let themeThreeObjectWhite = Color(hex: "F9F9F9")
    static let themeThreeObjectYellow = Color(hex: "FFEB3B")
    static let themeThreeObjectGreen = Color(hex: "81C784")
    static let themeThreeElementBlue = Color(hex: "64B5F6")
    static let themeThreeElementPink = Color(hex: "F06292")
    static let themeThreeNeutral = Color(hex: "DDDDDD")
    static let themeThreeInterface = Color(hex: "E0E0E0")

    init(hex: String) {
        let normalized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: normalized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch normalized.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
