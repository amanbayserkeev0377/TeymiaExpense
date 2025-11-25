import Foundation

/// Alternate app icons available for this app
/// Raw values match Icon Composer file names in project navigator
enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case light = "AppIcon-Light"
    case dark = "AppIcon-Dark"
    
    case bitcoin = "AppIcon-Bitcoin"
    case squareDollar = "AppIcon-SquareDollar"
    case washington = "AppIcon-Washington"
    
    case card = "AppIcon-Card"
    case cards = "AppIcon-Cards"
    case cards2 = "AppIcon-Cards2"
    
    case cards3 = "AppIcon-Cards3"
    case oneDollar = "AppIcon-OneDollar"
    case threeDollars = "AppIcon-ThreeDollars"
    
    var id: String { rawValue }
    
    /// Name for UIApplication.setAlternateIconName (nil for primary icon)
    var systemName: String? {
        self == .main ? nil : rawValue
    }
    
    /// Preview image name in Assets for UI display
    var previewImageName: String {
        "Preview-\(rawValue)"
    }
}
