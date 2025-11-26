import SwiftUI

extension View {
    func maxContentWidth(_ width: CGFloat = 600) -> some View {
        frame(maxWidth: width)
            .frame(maxWidth: .infinity)
    }
}



