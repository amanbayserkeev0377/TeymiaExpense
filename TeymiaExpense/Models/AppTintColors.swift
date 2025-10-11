import SwiftUI

// MARK: - App Tint Colors
struct AppTintColors {
    static let colors: [AppTintColor] = [
        .tint1, .tint2, .tint3, .tint4, .tint5, .tint6,
        .tint7, .tint8, .tint9, .tint10, .tint11, .tint12,
        .tint13, .tint14, .tint15, .tint16, .tint17,
        .tint18, .tint19, .tint20, .tint21
    ]
    
    static func color(at index: Int) -> Color {
        let tintColor = colors[index % colors.count]
        return tintColor.color
    }
}

// MARK: - App Tint Color
enum AppTintColor: String, CaseIterable, Codable {
    case tint1, tint2, tint3, tint4, tint5, tint6
    case tint7, tint8, tint9, tint10, tint11, tint12
    case tint13, tint14, tint15, tint16, tint17
    case tint18, tint19, tint20, tint21
    
    var color: Color {
        switch self {
        case .tint1:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.1882352941, green: 0.7843137255, blue: 0.6705882353, alpha: 1)
                : #colorLiteral(red: 0.0, green: 0.6431372549, blue: 0.5490196078, alpha: 1)
            })
        case .tint2:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
                : #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
            })
        case .tint3:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.9607843137, green: 0.3803921569, blue: 0.3411764706, alpha: 1)
                : #colorLiteral(red: 0.8431372549, green: 0.231372549, blue: 0.1921568627, alpha: 1)
            })
        case .tint4:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 1)
                : #colorLiteral(red: 0.9019607843, green: 0.5490196078, blue: 0, alpha: 1)
            })
        case .tint5:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.95, green: 0.85, blue: 0.15, alpha: 1)
                : #colorLiteral(red: 0.7843137255, green: 0.6274509804, blue: 0, alpha: 1)
            })
        case .tint6:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.3058823529, green: 0.8196078431, blue: 0.5176470588, alpha: 1)
                : #colorLiteral(red: 0.1411764706, green: 0.6274509804, blue: 0.3411764706, alpha: 1)
            })
        case .tint7:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.3568627451, green: 0.6588235294, blue: 0.9294117647, alpha: 1)
                : #colorLiteral(red: 0.1490196078, green: 0.4666666667, blue: 0.6784313725, alpha: 1)
            })
        case .tint8:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.737254902, green: 0.4823529412, blue: 0.8588235294, alpha: 1)
                : #colorLiteral(red: 0.5411764706, green: 0.3019607843, blue: 0.6352941176, alpha: 1)
            })
        case .tint9:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.9882352941, green: 0.6705882353, blue: 0.8196078431, alpha: 1)
                : #colorLiteral(red: 0.8705882353, green: 0.4, blue: 0.6117647059, alpha: 1)
            })
        case .tint10:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.611, green: 0.466, blue: 0.392, alpha: 1)
                : #colorLiteral(red: 0.694, green: 0.541, blue: 0.454, alpha: 1)
            })
        case .tint11:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.4196078431, green: 0.4666666667, blue: 0.8392156863, alpha: 1)
                : #colorLiteral(red: 0.2352941176, green: 0.2784313725, blue: 0.5607843137, alpha: 1)
            })
        case .tint12:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.713, green: 0.733, blue: 0.878, alpha: 1)
                : #colorLiteral(red: 0.576, green: 0.596, blue: 0.773, alpha: 1)
            })
        case .tint13:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.3882352941, green: 0.8235294118, blue: 1, alpha: 1)
                : #colorLiteral(red: 0.2509803922, green: 0.6823529412, blue: 0.8784313725, alpha: 1)
            })
        case .tint14:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.8911940455, green: 0.5065267682, blue: 0.7020475268, alpha: 1)
                : #colorLiteral(red: 0.8046556711, green: 0.4489571452, blue: 0.7656339407, alpha: 1)
            })
        case .tint15:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.6014889116, green: 0.4786262145, blue: 0.8774001837, alpha: 1)
                : #colorLiteral(red: 0.3254901961, green: 0.2039215686, blue: 0.6588235294, alpha: 1)
            })
        case .tint16:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.4784313725, green: 0.7176470588, blue: 0.7960784314, alpha: 1)
                : #colorLiteral(red: 0.231372549, green: 0.462745098, blue: 0.537254902, alpha: 1)
            })
        case .tint17:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 1, green: 0.568627451, blue: 0.4352941176, alpha: 1)
                : #colorLiteral(red: 1, green: 0.3725490196, blue: 0.4274509804, alpha: 1)
            })
        case .tint18:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.3529411765, green: 0.7490196078, blue: 0.1490196078, alpha: 1)
                : #colorLiteral(red: 0.2352941176, green: 0.4823529412, blue: 0.1019607843, alpha: 1)
            })
        case .tint19:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.6901960784, green: 0.7450980392, blue: 0.7725490196, alpha: 1)
                : #colorLiteral(red: 0.3764705882, green: 0.4901960784, blue: 0.5450980392, alpha: 1)
            })
        case .tint20:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.9844796062, green: 0.7052091956, blue: 0.1644336283, alpha: 1)
                : #colorLiteral(red: 0.9626899362, green: 0.5305011868, blue: 0.1816505194, alpha: 1)
            })
        case .tint21:
            return Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark
                ? #colorLiteral(red: 0.7475101948, green: 0.7774429917, blue: 0.8837624788, alpha: 1)
                : #colorLiteral(red: 0.7620564103, green: 0.6589847207, blue: 0.7723631263, alpha: 1)
            })
        }
    }
}
