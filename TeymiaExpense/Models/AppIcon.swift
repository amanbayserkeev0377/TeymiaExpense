import Foundation

/// Alternate app icons available for this app
/// Raw values match Icon Composer file names in project navigator
enum AppIcon: String, CaseIterable, Identifiable {
    case main = "AppIcon"
    case light = "AppIcon-Light"
    case dark = "AppIcon-Dark"
    case bitcoin = "AppIcon-Bitcoin"
    case blue = "AppIcon-Blue"
    case card = "AppIcon-Card"
    case cards = "AppIcon-Cards"
    case cards2 = "AppIcon-Cards2"
    case cards3 = "AppIcon-Cards3"
    case green = "AppIcon-Green"
    case greenPastel = "AppIcon-GreenPastel"
    case indigo = "AppIcon-Indigo"
    case oneDollar = "AppIcon-OneDollar"
    case orange = "AppIcon-Orange"
    case purple = "AppIcon-Purple"
    case red = "AppIcon-Red"
    case squareDollar = "AppIcon-SquareDollar"
    case threeDollars = "AppIcon-ThreeDollars"
    case washington = "AppIcon-Washington"
    
    var id: String { rawValue }
    
    /// Name for UIApplication.setAlternateIconName (nil for primary icon)
    var systemName: String? {
        self == .main ? nil : rawValue
    }
}
