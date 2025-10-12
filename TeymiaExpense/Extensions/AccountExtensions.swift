import Foundation
import SwiftUI

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
    
    var cardDarkColor: Color {
        return AccountColor.by(index: designIndex).colors.dark
    }
    
    var cardLightColor: Color {
        return AccountColor.by(index: designIndex).colors.light
    }
    
    var cardGradient: LinearGradient {
        return AccountColor.gradient(at: designIndex)
    }
    
    var cardIcon: String {
        return customIcon
    }
    
    var customUIImage: UIImage? {
        guard let imageData = customImageData else { return nil }
        return UIImage(data: imageData)
    }
}
