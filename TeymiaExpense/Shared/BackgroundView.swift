import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.mainBackground.ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.brandPrimary,
                    Color.brandSecondary,
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.brandPrimary.opacity(0.8),
                    Color.brandSecondary,
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 200
            )
            .ignoresSafeArea()
        }
    }
}
