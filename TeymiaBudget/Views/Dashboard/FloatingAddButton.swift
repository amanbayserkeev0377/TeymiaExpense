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
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                }
                .frame(width: 60, height: 60)
                .glassEffect(.regular.tint(.accentColor).interactive())
                .opacity(0.9)
                .buttonBorderShape(.circle)
                .clipShape(Circle())
                .shadow(color: .accentColor.opacity(0.2), radius: 7, x: 0, y: 2)
                .padding(20)
            }
        }
    }
}
