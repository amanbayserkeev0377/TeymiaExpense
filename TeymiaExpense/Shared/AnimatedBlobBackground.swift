import SwiftUI

// MARK: - Animated Blob Background

struct AnimatedBlobBackground: View {
    @State private var blobOffsets: [CGSize] = []
    
    var body: some View {
        Rectangle()
            .fill(.linearGradient(
                colors: [
                    Color(#colorLiteral(red: 0.3137254902, green: 0.8352941176, blue: 0.7176470588, alpha: 1)),
                    Color(#colorLiteral(red: 0.02352941176, green: 0.4901960784, blue: 0.4078431373, alpha: 1))
                ],
                startPoint: .top,
                endPoint: .bottom
            ))
            .mask {
                TimelineView(.animation(minimumInterval: 4.0, paused: false)) { timeline in
                    Canvas { context, size in
                        // MARK: Adding Filters for gooey effect
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        context.addFilter(.blur(radius: 30))
                        
                        // MARK: Drawing Layer
                        context.drawLayer { ctx in
                            // MARK: Placing Symbols
                            for index in 1...15 {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        // MARK: Generate 15 blobs with offsets from state
                        ForEach(1...15, id: \.self) { index in
                            BlobRectangle(
                                offset: blobOffsets.indices.contains(index - 1)
                                ? blobOffsets[index - 1]
                                : .zero
                            )
                            .tag(index)
                        }
                    }
                    .onChange(of: timeline.date) { oldValue, newValue in
                        // Generate new random positions (never return to center)
                        generateNewOffsets()
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                generateNewOffsets()
            }
    }
    
    // MARK: - Generate Random Offsets
    private func generateNewOffsets() {
        blobOffsets = (1...15).map { _ in
            CGSize(
                width: .random(in: -180...180),
                height: .random(in: -240...240)
            )
        }
    }
    
    @ViewBuilder
    private func BlobRectangle(offset: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.white)
            .frame(width: 80, height: 80)
            .offset(offset)
            .animation(.easeInOut(duration: 6), value: offset)
    }
}

// MARK: - Preview

#Preview("Animated Blob Background") {
    AnimatedBlobBackground()
}

#Preview("With Content") {
    ZStack {
        AnimatedBlobBackground()
        
        VStack(spacing: 20) {
            Text("Beautiful Blobs")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.15))
                .frame(height: 200)
                .overlay {
                    Text("Content on top")
                        .foregroundStyle(.white)
                }
        }
        .padding()
    }
}
