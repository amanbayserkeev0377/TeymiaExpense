import SwiftUI

// MARK: - Lively Floating Blobs Background (Lava Lamp Effect)

struct LivelyFloatingBlobsBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Clean base background
                Color.mainBackground
                    .ignoresSafeArea()
                
                // Blob 1 - Внешний круг (быстрый)
                LivelyBlob(
                    index: 0,
                    color: colorScheme == .dark
                        ? Color.mint
                    : Color.mint.opacity(0.5),
                    size: 210,
                    positions: [
                        CGPoint(x: geo.size.width * 0.15, y: geo.size.height * 0.2),  // Левый верх
                            CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.4),  // Левый центр
                            CGPoint(x: geo.size.width * 0.2, y: geo.size.height * 0.7),   // Левый низ
                            CGPoint(x: geo.size.width * 0.3, y: geo.size.height * 0.55),  // Чуть правее
                            CGPoint(x: geo.size.width * 0.18, y: geo.size.height * 0.35)  // Возврат
                    ],
                    duration: 4,
                    blur: 60
                )
                
                // Blob 2 - Средний круг (очень быстрый)
                LivelyBlob(
                    index: 1,
                    color: colorScheme == .dark
                    ? Color.purple.opacity(0.8)
                    : Color.purple.opacity(0.5),
                    size: 190,
                    positions: [
                        CGPoint(x: geo.size.width * 0.75, y: geo.size.height * 0.25), // Правый верх
                            CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.5),  // Правый центр
                            CGPoint(x: geo.size.width * 0.8, y: geo.size.height * 0.75),  // Правый низ
                            CGPoint(x: geo.size.width * 0.7, y: geo.size.height * 0.6),   // Чуть левее
                            CGPoint(x: geo.size.width * 0.82, y: geo.size.height * 0.4)   // Возврат
                    ],
                    duration: 5,
                    blur: 60
                )
                
                // Blob 3 - Внутренний круг (самый быстрый)
                LivelyBlob(
                    index: 2,
                    color: colorScheme == .dark
                        ? Color.blue.opacity(0.8)
                    : Color.blue.opacity(0.5),
                    size: 170,
                    positions: [
                        CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.3),   // Верх центр
                            CGPoint(x: geo.size.width * 0.55, y: geo.size.height * 0.5),  // Центр
                            CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.7),   // Низ центр
                            CGPoint(x: geo.size.width * 0.45, y: geo.size.height * 0.5)   // Центр левее
                    ],
                    duration: 3,
                    blur: 60
                )
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Single Lively Blob

struct LivelyBlob: View {
    let index: Int
    let color: Color
    let size: CGFloat
    let positions: [CGPoint]
    let duration: Double
    let blur: CGFloat
    
    @State private var currentIndex = 0
    
    private var currentPosition: CGPoint {
        positions[currentIndex % positions.count]
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        color,
                        color.opacity(0.7),
                        color.opacity(0.4),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blur)
            .position(currentPosition)
            .onAppear {
                // Разные начальные задержки для каждого шарика
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    startMoving()
                }
            }
    }
    
    private func startMoving() {
        withAnimation(
            .easeInOut(duration: duration)
        ) {
            currentIndex += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            startMoving()
        }
    }
}

// MARK: - Preview

#Preview("Dark Mode") {
    LivelyFloatingBlobsBackground()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    LivelyFloatingBlobsBackground()
        .preferredColorScheme(.light)
}

#Preview("With Content") {
    ZStack {
        LivelyFloatingBlobsBackground()
            .preferredColorScheme(.dark)
        
        VStack(spacing: 20) {
            Text("Content on top")
                .font(.largeTitle)
                .foregroundStyle(.white)
            
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.1))
                .frame(height: 200)
                .overlay {
                    Text("Glass Card")
                        .foregroundStyle(.white)
                }
        }
        .padding()
    }
}
