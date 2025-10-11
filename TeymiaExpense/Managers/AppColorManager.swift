import SwiftUI

@Observable
final class AppColorManager {
    static let shared = AppColorManager()
    
    var selectedColorIndex: Int = UserDefaults.standard.integer(forKey: "selectedAppColorIndex") {
        didSet {
            UserDefaults.standard.set(selectedColorIndex, forKey: "selectedAppColorIndex")
        }
    }
    
    var currentColor: Color {
        AccountColors.color(at: selectedColorIndex)
    }
    
    var currentGradient: LinearGradient {
        AccountColors.gradient(at: selectedColorIndex)
    }
    
    private init() {}
}

struct AppColor {
    static var current: Color {
        AppColorManager.shared.currentColor
    }
    
    static var currentGradient: LinearGradient {
        AppColorManager.shared.currentGradient
    }
}

extension Color {
    static var appTint: Color {
        AppColor.current
    }
    
    static var appGradient: LinearGradient {
        AppColor.currentGradient
    }
}

extension ShapeStyle where Self == Color {
    static var appTint: Color {
        Color.appTint
    }
}

extension LinearGradient {
    static var appGradient: LinearGradient {
        AppColor.currentGradient
    }
}
