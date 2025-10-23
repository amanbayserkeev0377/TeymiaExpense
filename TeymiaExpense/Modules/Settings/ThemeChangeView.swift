import SwiftUI

struct ThemeChangeView: View {
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    @Namespace private var animation
    
    @State private var circleOffset: CGSize
    
    init(scheme: ColorScheme) {
        self.scheme = scheme
        let isDark = scheme == .dark
        self._circleOffset = .init(initialValue: CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150))
    }
    
    var body: some View {
        VStack(spacing: 50) {
            Circle()
                .fill(userTheme.color(scheme).gradient)
                .frame(width: 150, height: 150)
                .mask {
                    Rectangle()
                        .overlay {
                            Circle()
                                .offset(circleOffset)
                                .blendMode(.destinationOut)
                        }
                }
            
            CustomSegmentedControl(
                options: Theme.allCases,
                titles: Theme.allCases.map { $0.rawValue },
                icons: ["circle.half", "sun", "moon"],
                iconSize: 18,
                gradients: [
                    LinearGradient(colors: [.primary], startPoint: .leading, endPoint: .trailing),
                    LinearGradient(colors: [.sun], startPoint: .leading, endPoint: .trailing),
                    LinearGradient(colors: [.moon], startPoint: .leading, endPoint: .trailing)
                ],
                selection: $userTheme
            )
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 40)
        .background(Color.mainRowBackground)
        .environment(\.colorScheme, scheme)
        .onChange(of: scheme) { _, newValue in
            let isDark = newValue == .dark
            withAnimation(.bouncy) {
                circleOffset = CGSize(width: isDark ? 30 : 150, height: isDark ? -25 : -150)
            }
        }
    }
}

enum Theme: String, CaseIterable, Hashable {
    case systemDefault = "Default"
    case light = "Light"
    case dark = "Dark"
    
    func color(_ scheme: ColorScheme) -> Color {
        switch self {
        case .systemDefault:
            return scheme == .dark ? .moon : .sun
        case .light:
            return .sun
        case .dark:
            return .moon
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .systemDefault:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    // MARK: - Computed Properties
    
    private var themeIcon: String {
        switch self {
        case .systemDefault:
            return "circle.half"
        case .light:
            return "sun"
        case .dark:
            return "moon"
        }
    }
}

extension Color {
    static let sun =  Color(#colorLiteral(red: 1, green: 0.5176470588, blue: 0.09803921569, alpha: 1))
    static let moon = Color(#colorLiteral(red: 0.5568627451, green: 0.5254901961, blue: 1, alpha: 1))
}
