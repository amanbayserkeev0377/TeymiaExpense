import SwiftUI

struct FloatingPlusButton: View {
    let action: () -> Void
    let animation: Namespace.ID?
    let useZoomTransition: Bool
    
    init(
        action: @escaping () -> Void,
        animation: Namespace.ID? = nil,
        useZoomTransition: Bool = false
    ) {
        self.action = action
        self.animation = animation
        self.useZoomTransition = useZoomTransition
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                button
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
            }
        }
    }
    
    @ViewBuilder
    private var button: some View {
        if useZoomTransition, let animation = animation {
            Button(action: action) {
                buttonContent
            }
            .frame(width: 60, height: 60)
            .applyGlassEffect()
            .clipShape(Circle())
            .contentShape(Circle())
            .shadow(color: AccountColors.color(at: 0).opacity(0.3), radius: 8, x: 0, y: 4)
            .matchedTransitionSource(id: "AddTransaction", in: animation)
        } else {
            Button(action: action) {
                buttonContent
            }
            .frame(width: 60, height: 60)
            .applyGlassEffect()
            .clipShape(Circle())
            .contentShape(Circle())
            .shadow(color: AccountColors.color(at: 0).opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private var buttonContent: some View {
        Image(systemName: "plus")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
    }
}

// MARK: - Glass Effect Extension

extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular.tint(AccountColors.color(at: 0).opacity(0.8)).interactive(), in: .circle)
        } else {
            self.background(
                Circle()
                    .fill(AccountColors.color(at: 0).opacity(0.8))
            )
        }
    }
}
