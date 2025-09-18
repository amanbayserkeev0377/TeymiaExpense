import Foundation
import SwiftUI
import SwiftData

// MARK: - Account Extensions
extension Account {
    var isDeletable: Bool {
        return !isDefault 
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: balance as NSDecimalNumber) ?? "0\(currency.symbol)"
    }
    
    var cardColor: Color {
        return AccountColors.color(at: colorIndex)
    }
    
    var cardDarkColor: Color {
        return AccountColors.darkColor(at: colorIndex)
    }
    
    var cardLightColor: Color {
        return AccountColors.lightColor(at: colorIndex)
    }
    
    var cardIcon: String {
        return customIcon
    }
}
