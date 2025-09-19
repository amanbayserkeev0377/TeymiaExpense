import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(AccountColors.color(at: 0).opacity(0.2))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.clear
                ]),
                center: .bottomLeading,
                startRadius: 5,
                endRadius: 400
            )
            .blendMode(.overlay)
            .edgesIgnoringSafeArea(.all)
        }
    }
}
