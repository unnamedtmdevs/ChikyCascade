import SwiftUI

struct AppTheme {
    let colors: AppColorScheme

    static let shared = AppTheme()

    private init() {
        colors = .shared
    }
}



