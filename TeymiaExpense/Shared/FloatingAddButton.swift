import SwiftUI

struct FloatingPlusButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: action) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .frame(width: 60, height: 60)
                .applyGlassEffect()
                .clipShape(Circle())
                .shadow(color: AccountColors.color(at: 0).opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.trailing, 20)
                .padding(.bottom, 60)
            }
        }
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
                    .fill(AccountColors.color(at: 0)).opacity(0.8)
            )
        }
    }
}
