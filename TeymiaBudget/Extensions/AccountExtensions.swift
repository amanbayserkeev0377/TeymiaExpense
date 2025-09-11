import Foundation
import SwiftUI
import SwiftData

// MARK: - Account Colors
struct AccountColors {
    static let colors: [Color] = [
        // Классические банковские цвета
        Color(red: 0.235, green: 0.482, blue: 0.984), // Blue
        Color(red: 0.961, green: 0.306, blue: 0.392), // Red
        Color(red: 0.298, green: 0.851, blue: 0.392), // Green
        Color(red: 0.961, green: 0.549, blue: 0.235), // Orange
        Color(red: 0.647, green: 0.4, blue: 0.961),   // Purple
        Color(red: 0.984, green: 0.784, blue: 0.188), // Yellow
        Color(red: 0.188, green: 0.784, blue: 0.671), // Teal
        Color(red: 0.937, green: 0.420, blue: 0.690), // Pink
    ]
    
    static func color(at index: Int) -> Color {
        return colors[index % colors.count]
    }
}

// MARK: - Account Extensions
extension Account {
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        return formatter.string(from: balance as NSDecimalNumber) ?? "\(currency.symbol)0.00"
    }
    
    var cardColor: Color {
        if let hexColor = customColorHex {
            return Color(hex: hexColor)
        }
        return type.color
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
        case .savings: return "savings"
        }
    }
    
    var color: Color {
        switch self {
        case .cash: return AccountColors.colors[2] // Green
        case .bankAccount: return AccountColors.colors[0] // Blue
        case .creditCard: return AccountColors.colors[3] // Orange
        case .savings: return AccountColors.colors[4] // Purple
        }
    }
    
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .bankAccount: return "Bank"
        case .creditCard: return "Card"
        case .savings: return "Savings"
        }
    }
}
