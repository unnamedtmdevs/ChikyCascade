import SwiftUI

struct AppTypography {
    struct FontFamily {
        static let heading = "SFProRounded-Semibold"
        static let body = "SFProText-Regular"
    }

    static func display(weight: Font.Weight = .bold) -> Font {
        Font.system(size: 32, weight: weight, design: .rounded)
    }

    static func title(weight: Font.Weight = .semibold) -> Font {
        Font.system(size: 24, weight: weight, design: .rounded)
    }

    static func headline(weight: Font.Weight = .medium) -> Font {
        Font.system(size: 20, weight: weight, design: .rounded)
    }

    static func body(weight: Font.Weight = .regular) -> Font {
        Font.system(size: 18, weight: weight, design: .default)
    }

    static func caption(weight: Font.Weight = .light) -> Font {
        Font.system(size: 14, weight: weight, design: .default)
    }
}



