import SwiftUI

@Observable
final class AppColorManager {
    static let shared = AppColorManager()
    
    // Separate indices for AppTint and Account Cards
    var selectedTintColorIndex: Int = UserDefaults.standard.integer(forKey: "selectedAppTintColorIndex") {
        didSet {
            UserDefaults.standard.set(selectedTintColorIndex, forKey: "selectedAppTintColorIndex")
        }
    }
    
    // Current AppTint color
    var currentTintColor: Color {
        AppTintColors.color(at: selectedTintColorIndex)
    }
    
    private init() {}
}

// MARK: - Global Access Helpers

struct AppColor {
    static var tint: Color {
        AppColorManager.shared.currentTintColor
    }
}

extension Color {
    static var appTint: Color {
        AppColor.tint
    }
}

extension ShapeStyle where Self == Color {
    static var appTint: Color {
        Color.appTint
    }
}
