import Foundation
import SwiftUI
import SwiftData

// MARK: - Account Extensions
extension Account {
    
    var formattedBalance: String {
        CurrencyFormatter.format(balance, currency: currency)
    }
    
    var cardColor: Color {
        return AccountColors.color(at: designIndex)
    }
    
    var cardDarkColor: Color {
        return AccountColors.darkColor(at: designIndex)
    }
    
    var cardLightColor: Color {
        return AccountColors.lightColor(at: designIndex)
    }
    
    var cardIcon: String {
        return customIcon
    }
}
