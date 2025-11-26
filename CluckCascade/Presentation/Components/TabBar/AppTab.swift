import SwiftUI

enum AppTab: Int, CaseIterable, Identifiable {
    case home
    case shop
    case medals
    case progress
    case settings

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .shop: return "Shop"
        case .medals: return "Medals"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .shop: return "cart"
        case .medals: return "rosette"
        case .progress: return "chart.line.uptrend.xyaxis"
        case .settings: return "gearshape"
        }
    }
}
