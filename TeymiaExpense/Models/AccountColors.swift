import SwiftUI

// MARK: - Account Colors
struct AccountColors {
    static let colors: [AccountColor] = [
        .color1, .color2, .color3, .color4, .color5, .color6,
        .color7, .color8, .color9, .color10, .color11, .color12,
        .color13, .color14, .color15, .color16, .color17,
        .color18, .color19, .color20, .color21
    ]
    
    // Dark color for gradients
    static func darkColor(at index: Int) -> Color {
        let accountColor = colors[index % colors.count]
        return accountColor.darkColor
    }
    
    // Light color for gradients
    static func lightColor(at index: Int) -> Color {
        let accountColor = colors[index % colors.count]
        return accountColor.lightColor
    }
    
    // Gradient for cards
    static func gradient(at index: Int) -> LinearGradient {
        return LinearGradient(
            colors: [
                darkColor(at: index),
                lightColor(at: index)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Account Color
enum AccountColor: String, CaseIterable, Codable {
    case color1, color2, color3, color4, color5, color6
    case color7, color8, color9, color10, color11, color12
    case color13, color14, color15, color16, color17
    case color18, color19, color20, color21
    
    var darkColor: Color {
        switch self {
        case .color1: return Color(#colorLiteral(red: 0.05, green: 0.5, blue: 0.42, alpha: 1))
        case .color2: return Color(#colorLiteral(red: 0.1803921569, green: 0.1803921569, blue: 0.1803921569, alpha: 1))
        case .color3: return Color(#colorLiteral(red: 0.65, green: 0.15, blue: 0.12, alpha: 1))
        case .color4: return Color(#colorLiteral(red: 0.7843, green: 0.3922, blue: 0, alpha: 1))
        case .color5: return Color(#colorLiteral(red: 0.75, green: 0.55, blue: 0.05, alpha: 1))
        case .color6: return Color(#colorLiteral(red: 0.12, green: 0.5, blue: 0.28, alpha: 1))
        case .color7: return Color(#colorLiteral(red: 0.12, green: 0.35, blue: 0.6, alpha: 1))
        case .color8: return Color(#colorLiteral(red: 0.45, green: 0.25, blue: 0.55, alpha: 1))
        case .color9: return Color(#colorLiteral(red: 0.75, green: 0.3, blue: 0.5, alpha: 1))
        case .color10: return Color(#colorLiteral(red: 0.45, green: 0.32, blue: 0.26, alpha: 1))
        case .color11: return Color(#colorLiteral(red: 0.15, green: 0.2, blue: 0.45, alpha: 1))
        case .color12: return Color(#colorLiteral(red: 0.4, green: 0.42, blue: 0.65, alpha: 1))
        case .color13: return Color(#colorLiteral(red: 0.15, green: 0.5, blue: 0.75, alpha: 1))
        case .color14: return Color(#colorLiteral(red: 0.7098039216, green: 0.1215686275, blue: 0.1019607843, alpha: 1))
        case .color15: return Color(#colorLiteral(red: 0.2705882353, green: 0.4078431373, blue: 0.862745098, alpha: 1))
        case .color16: return Color(#colorLiteral(red: 0.1176470588, green: 0.6823529412, blue: 0.5960784314, alpha: 1))
        case .color17: return Color(#colorLiteral(red: 1, green: 0.3725490196, blue: 0.4274509804, alpha: 1))
        case .color18: return Color(#colorLiteral(red: 0, green: 0.5725490196, blue: 0.2705882353, alpha: 1))
        case .color19: return Color(#colorLiteral(red: 0.2705882353, green: 0.3529411765, blue: 0.3921568627, alpha: 1))
        case .color20: return Color(#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1))
        case .color21: return Color(#colorLiteral(red: 0.03529411765, green: 0.1254901961, blue: 0.2470588235, alpha: 1))
        }
    }
    
    var lightColor: Color {
        switch self {
        case .color1: return Color(#colorLiteral(red: 0.25, green: 0.85, blue: 0.75, alpha: 1))
        case .color2: return Color(#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1))
        case .color3: return Color(#colorLiteral(red: 0.95, green: 0.5, blue: 0.45, alpha: 1))
        case .color4: return Color(#colorLiteral(red: 1, green: 0.706, blue: 0, alpha: 1))
        case .color5: return Color(#colorLiteral(red: 0.95, green: 0.85, blue: 0.15, alpha: 1))
        case .color6: return Color(#colorLiteral(red: 0.35, green: 0.85, blue: 0.55, alpha: 1))
        case .color7: return Color(#colorLiteral(red: 0.4, green: 0.7, blue: 0.95, alpha: 1))
        case .color8: return Color(#colorLiteral(red: 0.75, green: 0.55, blue: 0.9, alpha: 1))
        case .color9: return Color(#colorLiteral(red: 0.95, green: 0.7, blue: 0.85, alpha: 1))
        case .color10: return Color(#colorLiteral(red: 0.85, green: 0.7, blue: 0.6, alpha: 1))
        case .color11: return Color(#colorLiteral(red: 0.55, green: 0.6, blue: 0.9, alpha: 1))
        case .color12: return Color(#colorLiteral(red: 0.75, green: 0.77, blue: 0.9, alpha: 1))
        case .color13: return Color(#colorLiteral(red: 0.45, green: 0.85, blue: 0.95, alpha: 1))
        case .color14: return Color(#colorLiteral(red: 0.9764705882, green: 0.5568627451, blue: 0.9647058824, alpha: 1))
        case .color15: return Color(#colorLiteral(red: 0.6901960784, green: 0.4156862745, blue: 0.7019607843, alpha: 1))
        case .color16: return Color(#colorLiteral(red: 0.8470588235, green: 0.7098039216, blue: 1, alpha: 1))
        case .color17: return Color(#colorLiteral(red: 1, green: 0.7647058824, blue: 0.4431372549, alpha: 1))
        case .color18: return Color(#colorLiteral(red: 0.9882352941, green: 0.9333333333, blue: 0.1294117647, alpha: 1))
        case .color19: return Color(#colorLiteral(red: 0.6901960784, green: 0.7450980392, blue: 0.7725490196, alpha: 1))
        case .color20: return Color(#colorLiteral(red: 1, green: 0.706, blue: 0, alpha: 1))
        case .color21: return Color(#colorLiteral(red: 0.3254901961, green: 0.4705882353, blue: 0.5843137255, alpha: 1))
        }
    }
}
