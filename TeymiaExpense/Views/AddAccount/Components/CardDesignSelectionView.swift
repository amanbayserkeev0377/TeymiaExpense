import SwiftUI

struct CardDesignSelectionView: View {
    @Binding var selectedDesignType: AccountDesignType
    @Binding var selectedDesignIndex: Int
    
    var body: some View {
        Form {
            Section {
                Picker("Design Type", selection: $selectedDesignType) {
                    Text("photo").tag(AccountDesignType.image)
                    Text("color").tag(AccountDesignType.color)
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.clear)
            
            // Контент в секции с фоном
            Section {
                if selectedDesignType == .color {
                    colorSelectionView
                } else {
                    imageSelectionGrid
                }
            }
            .listRowBackground(Color.gray.opacity(0.1))
        }
        .listStyle(.plain)
        .listSectionSpacing(0)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - Image Selection Grid
    @ViewBuilder
    private var imageSelectionGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
            spacing: 12
        ) {
            ForEach(Array(AccountImageData.images.enumerated()), id: \.element.id) { index, imageData in
                imageDesignButton(index: index, imageData: imageData)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Color Selection View
    @ViewBuilder
    private var colorSelectionView: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
            spacing: 16
        ) {
            ForEach(0..<AccountColors.colors.count, id: \.self) { index in
                colorDesignButton(index: index)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Image Design Button
    @ViewBuilder
    private func imageDesignButton(index: Int, imageData: AccountImage) -> some View {
        Button {
            selectedDesignIndex = index
            selectedDesignType = .image
        } label: {
            Image(imageData.imageName)
                .resizable()
                .aspectRatio(16/10, contentMode: .fill)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (selectedDesignType == .image && selectedDesignIndex == index) ? .app : .clear,
                            lineWidth: 3
                        )
                )
                .scaleEffect((selectedDesignType == .image && selectedDesignIndex == index) ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selectedDesignIndex)
                .animation(.easeInOut(duration: 0.2), value: selectedDesignType)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Color Design Button
    @ViewBuilder
    private func colorDesignButton(index: Int) -> some View {
        Button {
            selectedDesignIndex = index
            selectedDesignType = .color
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AccountColors.gradient(at: index))
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                (selectedDesignType == .color && selectedDesignIndex == index) ? .app : .clear,
                                lineWidth: 3
                            )
                    )
            }
            .scaleEffect((selectedDesignType == .color && selectedDesignIndex == index) ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedDesignIndex)
            .animation(.easeInOut(duration: 0.2), value: selectedDesignType)
        }
        .buttonStyle(.plain)
    }
}
