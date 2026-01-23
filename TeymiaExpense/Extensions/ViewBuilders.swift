import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveButtonStyle() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

extension View {
    @ViewBuilder
    func adaptiveGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular.interactive(),
                in: Circle()
            )
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder
    func adaptiveGlassEffect(isEnabled: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                isEnabled ? .regular.tint(.primary).interactive() : .clear,
                in: Capsule()
            )
        } else {
            self
        }
    }
}
