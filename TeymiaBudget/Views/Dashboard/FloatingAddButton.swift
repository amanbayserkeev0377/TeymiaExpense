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
                        Circle()
                            .fill(AccountColors.gradient(at: 0)).opacity(0.2)
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(AccountColors.gradient(at: 0)).opacity(0.8)
                                    .frame(width: 52, height: 52)
                                    .shadow(
                                        color: AccountColors.color(at: 0).opacity(0.2),
                                        radius: 8,
                                        x: 0,
                                        y: 6
                                    )
                            )
                    }
                }
                .buttonStyle(.plain)
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }
}
