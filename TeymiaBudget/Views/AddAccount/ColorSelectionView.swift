import SwiftUI

struct ColorSelectionView: View {
    @Binding var selectedColorIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<AccountColors.colors.count, id: \.self) { index in
                    colorButton(index: index)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
        .padding(.vertical, 8)
    }
    
    private func colorButton(index: Int) -> some View {
        Button {
            selectedColorIndex = index
        } label: {
            ZStack {
                Circle()
                    .fill(AccountColors.color(at: index))
                    .frame(width: 50, height: 50)
                
                if selectedColorIndex == index {
                    Circle()
                        .stroke(.white, lineWidth: 3)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
