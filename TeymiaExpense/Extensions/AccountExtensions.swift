import Foundation
import SwiftUI
import SwiftData

// MARK: - Account Extensions
extension Account {
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: balance as NSDecimalNumber) ?? "0\(currency.symbol)"
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
