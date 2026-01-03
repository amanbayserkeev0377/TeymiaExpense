import SwiftUI
import PhotosUI

struct CardDesignSelectionSection: View {
    @Binding var selectedDesignType: AccountDesignType
    @Binding var selectedDesignIndex: Int
    @Binding var customImage: UIImage?
    @Binding var imageForCropping: UIImage?
    @Binding var showingPhotoPicker: Bool
    
    private let cornerRadius: CGFloat = 8
    private let frameWidth: CGFloat = 65
    private let frameHeight: CGFloat = 40
    private let lineWidth: CGFloat = 3
    
    private var imageColumns: [[AccountImage]] {
        stride(from: 0, to: AccountImageData.images.count, by: 3).map {
            Array(AccountImageData.images[$0..<min($0 + 3, AccountImageData.images.count)])
        }
    }
    
    private var colorColumns: [[Int]] {
        stride(from: 0, to: AccountColor.allCases.count, by: 3).map {
            Array($0..<min($0 + 3, AccountColor.allCases.count))
        }
    }
    
    var body: some View {
        Section {
            VStack(spacing: 16) {
                // Segmented Picker
                Picker("", selection: $selectedDesignType) {
                    Text("photo".localized).tag(AccountDesignType.image)
                    Text("color".localized).tag(AccountDesignType.color)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                
                // Scrollable Content
                if selectedDesignType == .color {
                    colorSelectionView
                } else {
                    imageSelectionView
                }
            }
            .padding(.vertical, 16)
        } header: {
            Text("design".localized)
                .padding(.leading, 16)
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
        .onChange(of: customImage) { oldValue, newValue in
            if newValue != nil {
                selectedDesignIndex = -1
            }
        }
    }
    
    // MARK: - Image Selection
    @ViewBuilder
    private var imageSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(imageColumns.indices, id: \.self) { columnIndex in
                    VStack(spacing: 12) {
                        ForEach(Array(imageColumns[columnIndex].enumerated()), id: \.element.id) { rowIndex, imageData in
                            let globalIndex = columnIndex * 3 + rowIndex
                            imageDesignButton(index: globalIndex, imageData: imageData)
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    customPhotoButton
                    Color.clear.frame(width: frameWidth, height: frameHeight)
                    Color.clear.frame(width: frameWidth, height: frameHeight)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Color Selection (3 Rows, Horizontal Scroll)
    @ViewBuilder
    private var colorSelectionView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(colorColumns.indices, id: \.self) { columnIndex in
                    VStack(spacing: 12) {
                        ForEach(colorColumns[columnIndex], id: \.self) { colorIndex in
                            colorDesignButton(index: colorIndex)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
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
                        .frame(width: frameWidth, height: frameHeight)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(
                                    selectedDesignIndex == -1 ? Color.primary : Color.clear,
                                    lineWidth: lineWidth
                                )
                        )
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.secondary.opacity(0.07))
                        .frame(width: frameWidth, height: frameHeight)
                        .overlay {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .strokeBorder(Color.primary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                }
            }
            .scaleEffect((selectedDesignIndex == -1 && customImage != nil) ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: selectedDesignIndex)
            .animation(.easeInOut(duration: 0.2), value: customImage)
        }
        .buttonStyle(.plain)
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
                .aspectRatio(contentMode: .fill)
                .frame(width: frameWidth, height: frameHeight)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            (selectedDesignType == .image && selectedDesignIndex == index) ? Color.primary : Color.clear,
                            lineWidth: lineWidth
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
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(AccountColor.gradient(at: index))
                .frame(width: frameWidth, height: frameHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            (selectedDesignType == .color && selectedDesignIndex == index) ? Color.primary : Color.clear,
                            lineWidth: lineWidth
                        )
                )
                .scaleEffect((selectedDesignType == .color && selectedDesignIndex == index) ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selectedDesignIndex)
                .animation(.easeInOut(duration: 0.2), value: selectedDesignType)
        }
        .buttonStyle(.plain)
    }
}
