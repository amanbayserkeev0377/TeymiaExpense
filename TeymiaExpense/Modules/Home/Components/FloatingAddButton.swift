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
        .glassEffect(.regular.tint(Color.primary).interactive(), in: .circle)
        .clipShape(Circle())
        .contentShape(Circle())
        .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        
        buttonView
    }
    
    private var buttonContent: some View {
        Image(systemName: "plus")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(.primaryInverse)
            .frame(width: 44, height: 44)
    }
}
