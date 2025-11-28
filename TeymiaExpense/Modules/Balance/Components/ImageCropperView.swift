import SwiftUI

struct ImageCropperView: View {
    let originalImage: UIImage
    let onCropComplete: (UIImage) -> Void
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var initialScale: CGFloat = 1.0
    
    // Constants
    private let targetAspectRatio: CGFloat = 16.0 / 10.0
    private let targetSize = CGSize(width: 1600, height: 1000)
    private let cornerRadius: CGFloat = 20.0
    private let maxScale: CGFloat = 5.0
    
    // Computed min scale - must always fill crop frame completely (no black areas)
    private var minScale: CGFloat {
        // Allow zooming out to 70% of initial scale, but ensure crop frame is always filled
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            return initialScale
        }
        
        let screenSize = window.bounds.size
        let cropFrameSize = calculateCropFrameSize(in: screenSize)
        let displayedImageSize = calculateDisplayedImageSize(
            imageSize: originalImage.size,
            containerSize: screenSize
        )
        
        // Calculate minimum scale needed to fill crop frame
        let minScaleX = cropFrameSize.width / displayedImageSize.width
        let minScaleY = cropFrameSize.height / displayedImageSize.height
        let absoluteMinScale = max(minScaleX, minScaleY)
        
        // Allow zooming out slightly, but not below what's needed to fill crop frame
        return max(absoluteMinScale, initialScale * 0.7)
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cropFrameSize = calculateCropFrameSize(in: geometry.size)
                
                ZStack {
                    Color.black
                        .ignoresSafeArea(.all)
                    
                    // Draggable and zoomable image
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .gesture(dragGesture(cropFrameSize: cropFrameSize, containerSize: geometry.size))
                        .gesture(magnificationGesture)
                        .simultaneousGesture(doubleTapGesture)
                        .onAppear {
                            // Calculate initial scale to fit image in crop frame
                            calculateInitialScale(
                                imageSize: originalImage.size,
                                cropFrameSize: cropFrameSize,
                                containerSize: geometry.size
                            )
                        }
                    
                    CropOverlayView(
                        cropFrameSize: cropFrameSize,
                        cornerRadius: cornerRadius
                    )
                    .ignoresSafeArea(.all)
                    
                    GridOverlayView(
                        cropFrameSize: cropFrameSize,
                        cornerRadius: cornerRadius
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(.all)
            .navigationTitle("Crop Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onCropComplete(originalImage)
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                    }
                    .tint(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            scale = initialScale
                            lastScale = initialScale
                            offset = .zero
                            lastOffset = .zero
                        }
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background {
                                TransparentBlurView(removeAllFilters: true)
                                    .blur(radius: 10, opaque: true)
                                    .background(Color.white.opacity(0.15))
                            }
                            .clipShape(Capsule())
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        cropImage()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                    }
                    .tint(.white)
                }
            }
        }
    }
    
    // MARK: - Initial Setup
    
    /// Calculate initial scale to ensure entire image fits in crop frame
    private func calculateInitialScale(imageSize: CGSize, cropFrameSize: CGSize, containerSize: CGSize) {
        let displayedImageSize = calculateDisplayedImageSize(
            imageSize: imageSize,
            containerSize: containerSize
        )
        
        // Calculate scale needed to fit image inside crop frame
        let scaleX = cropFrameSize.width / displayedImageSize.width
        let scaleY = cropFrameSize.height / displayedImageSize.height
        
        // Use the larger scale to ensure image covers crop frame
        let calculatedScale = max(scaleX, scaleY)
        
        // Start at a scale that shows more of the image (85% of what's needed to fill)
        // This allows user to zoom out more and see the full image
        initialScale = max(1.0, calculatedScale * 0.85)
        scale = initialScale
        lastScale = initialScale
        
        print("📐 Image: \(imageSize), Displayed: \(displayedImageSize), Crop: \(cropFrameSize)")
        print("🔍 Initial scale: \(initialScale)")
    }
    
    // MARK: - Gestures with Restricted Movement
    
    private func dragGesture(cropFrameSize: CGSize, containerSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                
                // Restrict offset to keep crop frame within image bounds
                offset = restrictOffset(
                    newOffset,
                    imageSize: originalImage.size,
                    cropSize: cropFrameSize,
                    containerSize: containerSize
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                let clampedScale = min(max(newScale, minScale), maxScale)
                scale = clampedScale
            }
            .onEnded { _ in
                // Ensure scale stays within bounds
                scale = min(max(scale, minScale), maxScale)
                lastScale = scale
                
                // Adjust offset to prevent black areas after scaling
                // But keep the current position instead of resetting to center
                guard let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first?.windows.first else {
                    return
                }
                
                let screenSize = window.bounds.size
                let cropFrameSize = calculateCropFrameSize(in: screenSize)
                
                offset = restrictOffset(
                    offset,
                    imageSize: originalImage.size,
                    cropSize: cropFrameSize,
                    containerSize: screenSize
                )
                lastOffset = offset
            }
    }
    
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if scale > initialScale * 1.2 {
                        // Reset to initial scale
                        scale = initialScale
                        offset = .zero
                    } else {
                        // Zoom in to 2x
                        scale = initialScale * 2.0
                    }
                    lastScale = scale
                    lastOffset = offset
                }
            }
    }
    
    // MARK: - Offset Restriction Logic
    
    /// Restricts offset to keep crop frame within image bounds (no black areas)
    private func restrictOffset(
        _ offset: CGSize,
        imageSize: CGSize,
        cropSize: CGSize,
        containerSize: CGSize
    ) -> CGSize {
        // Calculate the actual displayed image size in the container
        let displayedImageSize = calculateDisplayedImageSize(
            imageSize: imageSize,
            containerSize: containerSize
        )
        
        // Calculate the scaled image dimensions
        let scaledWidth = displayedImageSize.width * scale
        let scaledHeight = displayedImageSize.height * scale
        
        // Calculate maximum allowed offset to keep crop frame FULLY inside image
        // The crop frame must always be completely covered by image (no black areas)
        let maxOffsetX = max(0, (scaledWidth - cropSize.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - cropSize.height) / 2)
        
        // Clamp offset within allowed bounds
        return CGSize(
            width: max(-maxOffsetX, min(maxOffsetX, offset.width)),
            height: max(-maxOffsetY, min(maxOffsetY, offset.height))
        )
    }
    
    /// Calculate the actual displayed size of the image (before scaling)
    private func calculateDisplayedImageSize(imageSize: CGSize, containerSize: CGSize) -> CGSize {
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        if imageAspect > containerAspect {
            // Image is wider - fit to container width
            let width = containerSize.width
            let height = width / imageAspect
            return CGSize(width: width, height: height)
        } else {
            // Image is taller - fit to container height
            let height = containerSize.height
            let width = height * imageAspect
            return CGSize(width: width, height: height)
        }
    }
    
    // MARK: - Crop Frame Calculation
    
    private func calculateCropFrameSize(in containerSize: CGSize) -> CGSize {
        let width = containerSize.width * 0.9
        let height = width / targetAspectRatio
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Cropping Logic
    
    private func cropImage() {
        guard let croppedImage = performCrop() else {
            print("❌ Crop failed")
            return
        }
        
        onCropComplete(croppedImage)
    }
    
    private func performCrop() -> UIImage? {
        // Get actual screen size at crop time
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first else {
            print("❌ Failed to get window")
            return nil
        }
        
        let screenSize = window.bounds.size
        let cropFrameSize = calculateCropFrameSize(in: screenSize)
        let displayedImageSize = calculateDisplayedImageSize(
            imageSize: originalImage.size,
            containerSize: screenSize
        )
        
        // Calculate where the image actually is on screen
        let scaledImageWidth = displayedImageSize.width * scale
        let scaledImageHeight = displayedImageSize.height * scale
        
        // Image center position (accounting for offset)
        let imageCenterX = screenSize.width / 2 + offset.width
        let imageCenterY = screenSize.height / 2 + offset.height
        
        // Image frame on screen
        let imageFrameOnScreen = CGRect(
            x: imageCenterX - scaledImageWidth / 2,
            y: imageCenterY - scaledImageHeight / 2,
            width: scaledImageWidth,
            height: scaledImageHeight
        )
        
        // Crop frame on screen (centered)
        let cropFrameOnScreen = CGRect(
            x: (screenSize.width - cropFrameSize.width) / 2,
            y: (screenSize.height - cropFrameSize.height) / 2,
            width: cropFrameSize.width,
            height: cropFrameSize.height
        )
        
        // Calculate crop frame relative to the scaled image
        let cropInScaledImage = CGRect(
            x: cropFrameOnScreen.minX - imageFrameOnScreen.minX,
            y: cropFrameOnScreen.minY - imageFrameOnScreen.minY,
            width: cropFrameSize.width,
            height: cropFrameSize.height
        )
        
        // Convert to original image coordinates
        let scaleToOriginal = originalImage.size.width / displayedImageSize.width
        
        let cropInOriginalImage = CGRect(
            x: (cropInScaledImage.minX / scale) * scaleToOriginal,
            y: (cropInScaledImage.minY / scale) * scaleToOriginal,
            width: (cropInScaledImage.width / scale) * scaleToOriginal,
            height: (cropInScaledImage.height / scale) * scaleToOriginal
        )
        
        // Safety check - ensure crop rect is within bounds and has no black areas
        guard cropInOriginalImage.minX >= 0,
              cropInOriginalImage.minY >= 0,
              cropInOriginalImage.maxX <= originalImage.size.width,
              cropInOriginalImage.maxY <= originalImage.size.height,
              cropInOriginalImage.width > 0,
              cropInOriginalImage.height > 0 else {
            print("❌ Crop rect out of bounds or invalid: \(cropInOriginalImage)")
            print("   Original image size: \(originalImage.size)")
            return nil
        }
        
        // Perform the crop
        guard let cgImage = originalImage.cgImage?.cropping(to: cropInOriginalImage) else {
            print("❌ Failed to crop CGImage")
            return nil
        }
        
        let croppedUIImage = UIImage(
            cgImage: cgImage,
            scale: originalImage.scale,
            orientation: originalImage.imageOrientation
        )
        
        // Scale to target size with rounded corners
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: targetSize)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            path.addClip()
            croppedUIImage.draw(in: rect)
        }
    }
}

// MARK: - Crop Overlay View

struct CropOverlayView: View {
    let cropFrameSize: CGSize
    let cornerRadius: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: cropFrameSize.width, height: cropFrameSize.height)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .allowsHitTesting(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Grid Overlay View

struct GridOverlayView: View {
    let cropFrameSize: CGSize
    let cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 1)
                Spacer()
            }
            
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                Spacer()
            }
            
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.white, lineWidth: 2)
        }
        .frame(width: cropFrameSize.width, height: cropFrameSize.height)
        .allowsHitTesting(false)
    }
}
