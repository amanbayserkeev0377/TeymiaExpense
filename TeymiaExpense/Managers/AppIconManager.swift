import SwiftUI
import UIKit
import OSLog

@MainActor
@Observable
final class AppIconManager {
    static let shared = AppIconManager()
    
    private(set) var currentIcon: AppIcon
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TeymiaExpense", category: "AppIconManager")
    
    private init() {
        currentIcon = Self.getCurrentAppIcon()
    }
    
    /// Get current app icon from system
    static func getCurrentAppIcon() -> AppIcon {
        let currentName = UIApplication.shared.alternateIconName
        
        if let currentName, let icon = AppIcon(rawValue: currentName) {
            return icon
        }
        return .main
    }
    
    /// Set new app icon
    func setAppIcon(_ icon: AppIcon) {
        guard UIApplication.shared.supportsAlternateIcons else {
            logger.warning("Device does not support alternate icons")
            return
        }
        
        // Avoid setting if already using this icon
        guard currentIcon != icon else { return }
        
        // Set icon name to nil for primary icon
        let iconName = icon.systemName
        
        UIApplication.shared.setAlternateIconName(iconName) { [weak self] error in
            guard let self else { return }
            
            if let error {
                self.logger.error("Failed to set app icon: \(error)")
                
                Task { @MainActor in
                    // Revert to actual current icon on error
                    self.currentIcon = Self.getCurrentAppIcon()
                }
            } else {
                self.logger.info("Successfully set app icon to: \(icon.rawValue)")
            }
        }
        
        // Optimistically update UI
        currentIcon = icon
    }
}
