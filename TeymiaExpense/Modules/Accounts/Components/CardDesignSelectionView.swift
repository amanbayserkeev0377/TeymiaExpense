import SwiftUI
import PhotosUI

struct CardDesignSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDesignType: AccountDesignType
    @Binding var selectedDesignIndex: Int
    @Binding var customImage: UIImage?
    @Binding var shouldShowCropper: Bool // Signal to parent
    @Binding var imageForCropping: UIImage?
    
    @State private var showingPhotoPicker = false
    
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
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker { image in
                imageForCropping = image
                showingPhotoPicker = false
                
                // Close this sheet first, then signal parent
                dismiss()
            }
        }
        .onChange(of: customImage) { oldValue, newValue in
            if newValue != nil {
                selectedDesignIndex = -1
            }
        }
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
            
            customPhotoButton
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Custom Photo Button
    @ViewBuilder
    private var customPhotoButton: some View {
        Button {
            showingPhotoPicker = true
        } label: {
            ZStack {
                if let image = customImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedDesignIndex == -1 ? .appTint : .clear,
                                    lineWidth: 3
                                )
                        )
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 60)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.appTint)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appTint.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        )
                }
            }
            .frame(height: 60)
            .scaleEffect((selectedDesignIndex == -1 && customImage != nil) ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedDesignIndex)
            .animation(.easeInOut(duration: 0.2), value: customImage)
        }
        .buttonStyle(.plain)
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
            customImage = nil
        } label: {
            Image(imageData.imageName)
                .resizable()
                .aspectRatio(16/10, contentMode: .fill)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            (selectedDesignType == .image && selectedDesignIndex == index) ? .appTint : .clear,
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
            customImage = nil
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AccountColors.gradient(at: index))
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                (selectedDesignType == .color && selectedDesignIndex == index) ? .appTint : .clear,
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
