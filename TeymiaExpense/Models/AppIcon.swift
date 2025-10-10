import Foundation

enum AppIcon {
    case main
    case alternate(name: String, imageName: String)
    
    static let allIcons: [AppIcon] = [
        .main,
        .alternate(name: "AppIconDollar", imageName: "preview_appicon_dollar"),
        .alternate(name: "AppIconBitcoin", imageName: "preview_appicon_bitcoin"),
    ]
    
    /// Name for alternate icon (nil for main icon)
    var name: String? {
        switch self {
        case .main:
            return nil
        case .alternate(let name, _):
            return name
        }
    }
    
    /// Image name for preview in settings
    var imageName: String {
        switch self {
        case .main:
            return "preview_appicon_main"
        case .alternate(_, let imageName):
            return imageName
        }
    }
}

// MARK: - Conformances
extension AppIcon: Hashable, Identifiable {
    var id: String {
        switch self {
        case .main:
            return "main"
        case .alternate(let name, _):
            return name
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AppIcon: Equatable {
    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        lhs.id == rhs.id
    }
}
