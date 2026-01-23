import SwiftUI

struct CategoryIconView: View {
    let iconName: String
    let color: Color
    var size: CGFloat = 24
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isDark ? Color.black.gradient.opacity(0.2) : color.gradient.opacity(0.1))
            
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundStyle(color.gradient)
        }
        .frame(width: size * 1.8, height: size * 1.8)
        .overlay {
            if isDark {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .clear,
                                .clear,
                                .white.opacity(0.4),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
        }
    }
}

struct CategoryIconPreviewView: View {
    let iconName: String
    let color: Color
    let size: CGFloat = 50
    
    var body: some View {
        HStack {
            Spacer()
            CategoryIconView(iconName: iconName, color: color, size: size)
            Spacer()
        }
    }
}

