import Foundation
import SwiftUI
import SwiftData

// MARK: - Account Extensions
extension Account {
    
    var formattedBalance: String {
        let currency = self.currency ?? Currency(
            code: "USD",
            symbol: "$",
            name: "US Dollar",
            type: .fiat
        )
        return CurrencyFormatter.format(balance, currency: currency)
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
