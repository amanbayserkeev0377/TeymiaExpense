import SwiftUI

struct FloatingPlusButton: View {
    let action: () -> Void
    
    init(
        action: @escaping () -> Void,
    ) {
        self.action = action
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
        
        buttonView
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
            self.glassEffect(.regular.tint(Color.primary).interactive(), in: .circle)
        } else {
            self.background {
                ZStack {
                    // Blur background
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 2, opaque: true)
                    
                    // Color overlay
                    Circle()
                        .fill(Color.primary.opacity(0.7))
                }
                .clipShape(Circle())
            }
        }
    }
}
