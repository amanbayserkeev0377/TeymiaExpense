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
        let buttonView = Button(action: action) {
            buttonContent
        }
        .frame(width: 60, height: 60)
        .applyGlassEffect()
        .clipShape(Circle())
        .contentShape(Circle())
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        
        if useZoomTransition, let animation = animation {
            buttonView.matchedTransitionSource(id: "AddTransaction", in: animation)
        } else {
            buttonView
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
            self.glassEffect(.regular.tint(Color.appTint).interactive(), in: .circle)
        } else {
            self.background {
                ZStack {
                    // Blur background
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 2, opaque: true)
                    
                    // Color overlay
                    Circle()
                        .fill(Color.appTint.opacity(0.8))
                }
                .clipShape(Circle())
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.6),
                                .white.opacity(0.1),
                                .white.opacity(0.1),
                                .white.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
        }
    }
}
