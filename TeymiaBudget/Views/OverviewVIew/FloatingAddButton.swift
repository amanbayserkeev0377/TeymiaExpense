import SwiftUI

struct FloatingAddButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action: action) {
                    ZStack {
                        // Outer circle with subtle background
                        Circle()
                            .fill(.accent.opacity(0.2))
                            .frame(width: 64, height: 64)
                        
                        Image("plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(.accent.gradient.opacity(0.8))
                                    .frame(width: 52, height: 52)
                                    .shadow(
                                        color: .accent.opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 6
                                    )
                            )
                    }
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 120) // Above tab bar
            }
        }
    }
}
