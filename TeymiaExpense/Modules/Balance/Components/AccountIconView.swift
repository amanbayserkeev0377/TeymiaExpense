import SwiftUI

struct AccountIconView: View {
    let iconName: String
    let color: Color
    var size: CGFloat = 20
    var cornerRadius: CGFloat = 8
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        ZStack {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundStyle(isDark ? color.gradient : Color.white.gradient)
        }
        .frame(width: size * 1.8, height: size * 1.8)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isDark ? Color.black.gradient.opacity(0.2) : color.gradient.opacity(0.9))
        }
        .overlay {
            if isDark {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                .clear,
                                .clear,
                                .white.opacity(0.4)
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

struct AccountIconPreviewView: View {
    let iconName: String
    let color: Color
    var size: CGFloat = 50
    var cornerRadius: CGFloat = 24
    
    var body: some View {
        HStack {
            Spacer()
            AccountIconView(iconName: iconName, color: color, size: size, cornerRadius: cornerRadius)
            Spacer()
        }
    }
}

