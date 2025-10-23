import SwiftUI

// MARK: - Header Button Model

struct HeaderButton {
    let icon: String
    let iconSize: CGFloat
    let action: () -> Void
    
    init(icon: String, iconSize: CGFloat = 30, action: @escaping () -> Void) {
        self.icon = icon
        self.iconSize = iconSize
        self.action = action
    }
}

// MARK: - Blur Navigation View
/// Reusable view with custom blur header for consistent UI across all screens
struct BlurNavigationView<Content: View>: View {
    let title: String?
    let showBackButton: Bool
    let leadingButton: HeaderButton?
    let trailingButton: HeaderButton?
    @ViewBuilder let content: () -> Content
    
    @Environment(\.dismiss) private var dismiss
    
    init(
        title: String? = nil,
        showBackButton: Bool = false,
        leadingButton: HeaderButton? = nil,
        trailingButton: HeaderButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let safeArea = geometry.safeAreaInsets
            
            ZStack(alignment: .top) {
                // Content with built-in ScrollView
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        // Spacer for header
                        Color.clear
                            .frame(height: 100 + safeArea.top)
                        
                        content()
                            .padding(.top, 20)
                    }
                }
                
                // Custom Blur Header (fixed on top)
                VStack(spacing: 0) {
                    TransparentBlurView(removeAllFilters: true)
                        .blur(radius: 8, opaque: false)
                        .padding([.horizontal, .top], -30)
                        .overlay(alignment: .bottom) {
                            HStack(spacing: 12) {
                                // Leading button (back or custom)
                                if showBackButton {
                                    Button {
                                        dismiss()
                                    } label: {
                                        Image("chevron.left")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(.appTint)
                                    }
                                    .buttonStyle(CircleButtonStyle())
                                } else if let leading = leadingButton {
                                    Button(action: leading.action) {
                                        Image(leading.icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: leading.iconSize, height: leading.iconSize)
                                            .foregroundStyle(.appTint)
                                    }
                                    .buttonStyle(CircleButtonStyle())
                                } else {
                                    // Invisible spacer to balance layout when no leading button
                                    Spacer()
                                        .frame(width: 44, height: 44)
                                }
                                
                                Spacer()
                                
                                // Inline title (centered in header)
                                if let title = title {
                                    Text(title)
                                        .font(.headline)
                                        .fontDesign(.rounded)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                                
                                Spacer()
                                
                                // Trailing button
                                if let trailing = trailingButton {
                                    Button(action: trailing.action) {
                                        Image(trailing.icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: trailing.iconSize, height: trailing.iconSize)
                                            .foregroundStyle(.appTint)
                                    }
                                    .buttonStyle(CircleButtonStyle())
                                } else {
                                    // Invisible spacer to balance layout when no trailing button
                                    Spacer()
                                        .frame(width: 44, height: 44)
                                }
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 44)
                            .padding(.bottom, 8)
                        }
                        .frame(height: 100 + safeArea.top)
                        .padding(.top, -safeArea.top)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
}

// MARK: - Circle Button Style

struct CircleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if #available(iOS 26, *) {
                // iOS 26: Native Liquid Glass effect
                configuration.label
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.interactive(), in: .circle)
            } else {
                // iOS 17-25: Custom TransparentBlur effect
                configuration.label
                    .frame(width: 44, height: 44)
                    .background {
                        ZStack {
                            Circle()
                                .fill(Color.mainRowBackground)
                            
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(0.6),
                                            .white.opacity(0.1),
                                            .white.opacity(0.1),
                                            .white.opacity(0.6),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                        .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
                    .contentShape(Circle())
            }
        }
    }
}
