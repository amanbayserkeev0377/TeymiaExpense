import SwiftUI

struct ImageCropperView: View {
    @Environment(\.dismiss) private var dismiss
    let originalImage: UIImage
    let onCropComplete: (UIImage) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let targetAspectRatio: CGFloat = 16.0 / 10.0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cropFrameSize = calculateCropFrameSize(in: geometry.size)
                
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    // Image with gestures
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    let newScale = scale * delta
                                    scale = min(max(newScale, 1.0), 5.0)
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                    
                    // Crop overlay (non-interactive)
                    CropFrameOverlay(frameSize: cropFrameSize)
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("Adjust Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cropImage()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.9), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
    
    // MARK: - Calculate Crop Frame
    
    private func calculateCropFrameSize(in containerSize: CGSize) -> CGSize {
        let padding: CGFloat = 40
        let maxWidth = containerSize.width - padding * 2
        let maxHeight = containerSize.height - padding * 2
        
        let width = min(maxWidth, maxHeight * targetAspectRatio)
        let height = width / targetAspectRatio
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Crop Image
    
    private func cropImage() {
        guard let croppedImage = performCrop() else {
            print("❌ Crop failed")
            dismiss()
            return
        }
        onCropComplete(croppedImage)
        dismiss()
    }
    
    private func performCrop() -> UIImage? {
        // Use actual screen size
        let screenSize = UIScreen.main.bounds.size
        let cropFrameSize = calculateCropFrameSize(in: screenSize)
        
        // Crop frame centered on screen
        let cropFrame = CGRect(
            x: (screenSize.width - cropFrameSize.width) / 2,
            y: (screenSize.height - cropFrameSize.height) / 2,
            width: cropFrameSize.width,
            height: cropFrameSize.height
        )
        
        // Calculate how image is displayed
        let imageSize = originalImage.size
        let imageAspect = imageSize.width / imageSize.height
        let screenAspect = screenSize.width / screenSize.height
        
        // Base image frame (fit to screen)
        var baseImageFrame: CGRect
        if imageAspect > screenAspect {
            // Image is wider - fit to width
            let displayWidth = screenSize.width
            let displayHeight = displayWidth / imageAspect
            baseImageFrame = CGRect(
                x: 0,
                y: (screenSize.height - displayHeight) / 2,
                width: displayWidth,
                height: displayHeight
            )
        } else {
            // Image is taller - fit to height
            let displayHeight = screenSize.height
            let displayWidth = displayHeight * imageAspect
            baseImageFrame = CGRect(
                x: (screenSize.width - displayWidth) / 2,
                y: 0,
                width: displayWidth,
                height: displayHeight
            )
        }
        
        // Apply user's scale
        let scaledSize = CGSize(
            width: baseImageFrame.width * scale,
            height: baseImageFrame.height * scale
        )
        
        // Apply user's offset
        let displayFrame = CGRect(
            x: baseImageFrame.midX - scaledSize.width / 2 + offset.width,
            y: baseImageFrame.midY - scaledSize.height / 2 + offset.height,
            width: scaledSize.width,
            height: scaledSize.height
        )
        
        // Calculate crop rectangle in original image coordinates
        let scaleX = imageSize.width / displayFrame.width
        let scaleY = imageSize.height / displayFrame.height
        
        let cropX = (cropFrame.minX - displayFrame.minX) * scaleX
        let cropY = (cropFrame.minY - displayFrame.minY) * scaleY
        let cropWidth = cropFrameSize.width * scaleX
        let cropHeight = cropFrameSize.height * scaleY
        
        // Ensure valid crop rect
        let clampedX = max(0, min(cropX, imageSize.width))
        let clampedY = max(0, min(cropY, imageSize.height))
        let clampedWidth = max(0, min(cropWidth, imageSize.width - clampedX))
        let clampedHeight = max(0, min(cropHeight, imageSize.height - clampedY))
        
        guard clampedWidth > 0, clampedHeight > 0 else {
            print("❌ Invalid crop dimensions")
            return nil
        }
        
        let cropRect = CGRect(
            x: clampedX,
            y: clampedY,
            width: clampedWidth,
            height: clampedHeight
        )
        
        // Crop
        guard let cgImage = originalImage.cgImage?.cropping(to: cropRect) else {
            print("❌ Failed to crop cgImage")
            return nil
        }
        
        // Resize to target size
        let croppedImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        let targetSize = CGSize(width: 1600, height: 1000)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

// MARK: - Crop Frame Overlay

struct CropFrameOverlay: View {
    let frameSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.6)).ignoresSafeArea()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .blendMode(.destinationOut)
                            .frame(width: frameSize.width, height: frameSize.height)
                    )
                    .compositingGroup()
                
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(width: frameSize.width, height: frameSize.height)
                
                GridOverlay(frameSize: frameSize)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}

// MARK: - Grid Overlay

struct GridOverlay: View {
    let frameSize: CGSize
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1)
                Spacer()
            }
            .frame(width: frameSize.width)
            
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                Spacer()
            }
            .frame(height: frameSize.height)
        }
    }
}
