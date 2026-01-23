import SwiftUI

struct FloatingAddButton: View {
    let action: () -> Void
    let namespace: Namespace.ID
        
    var body: some View {
        Button(action: action) {
            ZStack  {
                Circle()
                    .fill(.primary)
                    .frame(width: 60, height: 60)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primaryInverse)
            }
        }
        .applyGlassEffect()
        .clipShape(Circle())
        .contentShape(Circle())
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .matchedTransitionSource(id: "ADDTRANSACTION", in: namespace)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}

extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(.primary).interactive(), in: .circle)
        } else {
            self
        }
    }
}
