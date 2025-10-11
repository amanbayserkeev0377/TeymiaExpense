import SwiftUI
import UIKit

@Observable
final class AppIconManager {
    static let shared = AppIconManager()
    
    private(set) var currentIcon: AppIcon
    
    private init() {
        currentIcon = Self.getCurrentAppIcon()
    }
    
    static func getCurrentAppIcon() -> AppIcon {
        let currentName = UIApplication.shared.alternateIconName
        return AppIcon.allIcons.first { $0.name == currentName } ?? .main
    }
    
    func setAppIcon(_ icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else { return }
        guard currentIcon != icon else { return }
        
        currentIcon = icon
        
        UIApplication.shared.setAlternateIconName(icon.name) { [weak self] error in
            if let error = error {
                Task { @MainActor in
                    self?.currentIcon = Self.getCurrentAppIcon()
                }
                print("Failed to set app icon: \(error)")
            }
        }
    }
}
