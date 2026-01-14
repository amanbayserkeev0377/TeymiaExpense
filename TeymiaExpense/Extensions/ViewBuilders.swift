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

extension View {
    @ViewBuilder
    func adaptiveSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.fullScreenCover(item: item, content: content)
        } else {
            self.sheet(item: item, content: content)
        }
    }
}

extension View {
    @ViewBuilder
    func adaptiveSheet(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.fullScreenCover(isPresented: isPresented, content: content)
        } else {
            self.sheet(isPresented: isPresented, content: content)
        }
    }
}
