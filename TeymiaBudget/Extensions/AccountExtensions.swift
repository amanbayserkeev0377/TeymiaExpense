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
        return AccountColors.color(at: colorIndex)
    }
    
    var cardDarkColor: Color {
        return AccountColors.darkColor(at: colorIndex)
    }
    
    var cardLightColor: Color {
        return AccountColors.lightColor(at: colorIndex)
    }
    
    var cardIcon: String {
        return customIcon ?? type.iconName
    }
}

// MARK: - AccountType Extensions
extension AccountType {
    var iconName: String {
        switch self {
        case .cash: return "cash"
        case .bankAccount: return "bank"
        case .creditCard: return "credit.card"
        case .savings: return "piggy.bank"
        }
    }
        
    var displayName: String {
        switch self {
        case .cash: return "cash".localized
        case .bankAccount: return "bank".localized
        case .creditCard: return "card".localized
        case .savings: return "savings".localized
        }
    }
}
