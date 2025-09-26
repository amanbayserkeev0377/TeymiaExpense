import Foundation
import SwiftUI

@Observable
class UserPreferences {
    var baseCurrencyCode: String {
        didSet {
            UserDefaults.standard.set(baseCurrencyCode, forKey: "userBaseCurrencyCode")
        }
    }
    
    init() {
        let savedCurrency = UserDefaults.standard.string(forKey: "userBaseCurrencyCode")
        self.baseCurrencyCode = savedCurrency ?? CurrencyData.detectUserCurrency()
    }
    
    func getBaseCurrency(from currencies: [Currency]) -> Currency? {
        return currencies.first { $0.code == baseCurrencyCode }
    }
}

extension UserPreferences {
    func formatAmount(_ amount: Decimal, currencies: [Currency]) -> String {
        guard let baseCurrency = getBaseCurrency(from: currencies) else {
            return "\(amount)"
        }
        return amount.formatted(currency: baseCurrency)
    }
}
