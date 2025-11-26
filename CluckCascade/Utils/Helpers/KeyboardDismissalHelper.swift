import SwiftUI
import UIKit

enum KeyboardDismissalHelper {
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func keyboardDismissable() -> some View {
        onTapGesture {
            KeyboardDismissalHelper.dismissKeyboard()
        }
    }
}

