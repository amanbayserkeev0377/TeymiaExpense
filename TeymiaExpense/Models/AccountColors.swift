import SwiftUI

// MARK: - Account Color
enum AccountColor: String, CaseIterable, Codable {
    case color1, color2, color3, color4, color5, color6
    case color7, color8, color9, color10, color11, color12
    case color13, color14, color15, color16, color17, color18
    case color19, color20, color21, color22, color23
    case color24, color25, color26, color27
    
    var colors: (dark: Color, light: Color) {
        switch self {
        case .color1: return (Color(#colorLiteral(red: 0.05, green: 0.5, blue: 0.42, alpha: 1)), Color(#colorLiteral(red: 0.25, green: 0.85, blue: 0.75, alpha: 1)))
        case .color2: return (Color(#colorLiteral(red: 0.18, green: 0.18, blue: 0.18, alpha: 1)), Color(#colorLiteral(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)))
        case .color3: return (Color(#colorLiteral(red: 0.65, green: 0.15, blue: 0.12, alpha: 1)), Color(#colorLiteral(red: 0.95, green: 0.5, blue: 0.45, alpha: 1)))
        case .color4: return (Color(#colorLiteral(red: 0.78, green: 0.39, blue: 0, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.71, blue: 0, alpha: 1)))
        case .color5: return (Color(#colorLiteral(red: 0.75, green: 0.55, blue: 0.05, alpha: 1)), Color(#colorLiteral(red: 0.95, green: 0.85, blue: 0.15, alpha: 1)))
        case .color6: return (Color(#colorLiteral(red: 0.12, green: 0.5, blue: 0.28, alpha: 1)), Color(#colorLiteral(red: 0.35, green: 0.85, blue: 0.55, alpha: 1)))
        case .color7: return (Color(#colorLiteral(red: 0.12, green: 0.35, blue: 0.6, alpha: 1)), Color(#colorLiteral(red: 0.4, green: 0.7, blue: 0.95, alpha: 1)))
        case .color8: return (Color(#colorLiteral(red: 0.45, green: 0.25, blue: 0.55, alpha: 1)), Color(#colorLiteral(red: 0.75, green: 0.55, blue: 0.9, alpha: 1)))
        case .color9: return (Color(#colorLiteral(red: 0.75, green: 0.3, blue: 0.5, alpha: 1)), Color(#colorLiteral(red: 0.95, green: 0.7, blue: 0.85, alpha: 1)))
        case .color10: return (Color(#colorLiteral(red: 0.45, green: 0.32, blue: 0.26, alpha: 1)), Color(#colorLiteral(red: 0.85, green: 0.7, blue: 0.6, alpha: 1)))
        case .color11: return (Color(#colorLiteral(red: 0.15, green: 0.2, blue: 0.45, alpha: 1)), Color(#colorLiteral(red: 0.55, green: 0.6, blue: 0.9, alpha: 1)))
        case .color12: return (Color(#colorLiteral(red: 0.4, green: 0.42, blue: 0.65, alpha: 1)), Color(#colorLiteral(red: 0.75, green: 0.77, blue: 0.9, alpha: 1)))
        case .color13: return (Color(#colorLiteral(red: 0.15, green: 0.5, blue: 0.75, alpha: 1)), Color(#colorLiteral(red: 0.45, green: 0.85, blue: 0.95, alpha: 1)))
        case .color14: return (Color(#colorLiteral(red: 0.71, green: 0.12, blue: 0.1, alpha: 1)), Color(#colorLiteral(red: 0.98, green: 0.56, blue: 0.96, alpha: 1)))
        case .color15: return (Color(#colorLiteral(red: 0.27, green: 0.41, blue: 0.86, alpha: 1)), Color(#colorLiteral(red: 0.69, green: 0.42, blue: 0.7, alpha: 1)))
        case .color16: return (Color(#colorLiteral(red: 0.12, green: 0.68, blue: 0.6, alpha: 1)), Color(#colorLiteral(red: 0.85, green: 0.71, blue: 1, alpha: 1)))
        case .color17: return (Color(#colorLiteral(red: 1, green: 0.37, blue: 0.43, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.76, blue: 0.44, alpha: 1)))
        case .color18: return (Color(#colorLiteral(red: 0, green: 0.57, blue: 0.27, alpha: 1)), Color(#colorLiteral(red: 0.99, green: 0.93, blue: 0.13, alpha: 1)))
        case .color19: return (Color(#colorLiteral(red: 0.27, green: 0.35, blue: 0.39, alpha: 1)), Color(#colorLiteral(red: 0.69, green: 0.75, blue: 0.77, alpha: 1)))
        case .color20: return (Color(#colorLiteral(red: 1, green: 0.15, blue: 0, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.71, blue: 0, alpha: 1)))
        case .color21: return (Color(#colorLiteral(red: 1, green: 0.6509803922, blue: 0.6196078431, alpha: 1)), Color(#colorLiteral(red: 0.5254901961, green: 0.0862745098, blue: 0.3411764706, alpha: 1)))
        case .color22: return (Color(#colorLiteral(red: 0.33, green: 0.47, blue: 0.58, alpha: 1)), Color(#colorLiteral(red: 0.04, green: 0.13, blue: 0.25, alpha: 1)))
        case .color23: return (Color(#colorLiteral(red: 0.5019607843, green: 0.8156862745, blue: 0.7803921569, alpha: 1)), Color(#colorLiteral(red: 0.07450980392, green: 0.3294117647, blue: 0.4784313725, alpha: 1)))
        case .color24: return (Color(#colorLiteral(red: 1, green: 0.9137254902, blue: 0.5215686275, alpha: 1)), Color(#colorLiteral(red: 0.9803921569, green: 0.4549019608, blue: 0.168627451, alpha: 1)))
        case .color25: return (Color(#colorLiteral(red: 0.9921568627, green: 0.3960784314, blue: 0.5215686275, alpha: 1)), Color(#colorLiteral(red: 0.05098039216, green: 0.1450980392, blue: 0.7254901961, alpha: 1)))
        case .color26: return (Color(#colorLiteral(red: 0.9607843137, green: 0.7960784314, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.7647058824, green: 0.2745098039, blue: 0.7607843137, alpha: 1)))
        case .color27: return (Color(#colorLiteral(red: 0.8901960784, green: 0.8901960784, blue: 0.8901960784, alpha: 1)), Color(#colorLiteral(red: 0.05490196078, green: 0.3607843137, blue: 0.6784313725, alpha: 1)))
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [colors.dark, colors.light],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func by(index: Int) -> AccountColor {
        let cases = Self.allCases
        return cases[index % cases.count]
    }
    
    static func gradient(at index: Int) -> LinearGradient {
        return self.by(index: index).gradient
    }
}
