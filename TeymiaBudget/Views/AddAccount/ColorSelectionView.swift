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
                    .frame(width: 32, height: 32)

                if selectedColorIndex == index {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
