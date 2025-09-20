import SwiftUI
//
//struct FloatingAddButton: View {
//    @Environment(\.colorScheme) private var colorScheme
//    let action: () -> Void
//    
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                
//                Button(action: action) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundStyle(.white)
//                        .frame(width: 44, height: 44)
//                }
//                .frame(width: 60, height: 60)
//                .glassEffect(.regular.tint(.accentColor).interactive())
//                .opacity(0.9)
//                .buttonBorderShape(.circle)
//                .clipShape(Circle())
//                .shadow(color: .accentColor.opacity(0.2), radius: 7, x: 0, y: 2)
//                .padding(20)
//            }
//        }
//    }
//}
//


struct FloatingAddButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .font(.system(size: 16, weight: .bold))
            
            Text("Add Transaction")
                .font(.system(.callout, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
