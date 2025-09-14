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
        .padding(.top, 2)
    }
    
    private func colorButton(index: Int) -> some View {
        Button {
            selectedColorIndex = index
        } label: {
            ZStack {
                Circle()
                    .fill(AccountColors.gradient(at: index))
                    .frame(width: 28, height: 28)
                
                if selectedColorIndex == index {
                    Image("check")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
