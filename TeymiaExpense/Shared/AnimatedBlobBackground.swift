
import SwiftUI

// MARK: - Animated Blob Background

struct AnimatedBlobBackground: View {
    @State private var blobOffsets: [CGSize] = []
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            Image("neon-dark")
                .resizable()
                .ignoresSafeArea()
            
            Rectangle()
                .fill(Color(#colorLiteral(red: 0, green: 0.8159179091, blue: 0.5566406846, alpha: 1)))
                .mask {
                    TimelineView(.animation(minimumInterval: 5.0, paused: false)) { timeline in
                        Canvas { context, size in
                            context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            context.addFilter(.blur(radius: 30))
                            context.drawLayer { ctx in
                                for index in 1...15 {
                                    if let resolvedView = context.resolveSymbol(id: index) {
                                        ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                    }
                                }
                            }
                        } symbols: {
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
                            generateNewOffsets()
                        }
                    }
                }
                .blur(radius: 10)
                .opacity(isReady ? 0.1 : 0)
                .animation(.easeIn(duration: 2.0), value: isReady)
//                .ignoresSafeArea()
                .task {
                    generateNewOffsets()
                    try? await Task.sleep(for: .milliseconds(50))
                    generateNewOffsets()
                    try? await Task.sleep(for: .milliseconds(1000))
                    isReady = true
                }
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
            .animation(.easeInOut(duration: 8), value: offset)
    }
}

#Preview {
    AnimatedBlobBackground()
}
