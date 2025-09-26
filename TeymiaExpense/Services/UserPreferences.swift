import Foundation
import SwiftUI

@Observable
class UserPreferences {
    var baseCurrencyCode: String {
        didSet {
            UserDefaults.standard.set(baseCurrencyCode, forKey: "userBaseCurrencyCode")
        }
    }
    
    var lastUsedAccountName: String? {
        didSet {
            if let name = lastUsedAccountName {
                UserDefaults.standard.set(name, forKey: "lastUsedAccountName")
            } else {
                UserDefaults.standard.removeObject(forKey: "lastUsedAccountName")
            }
        }
    }
    
    init() {
        let savedCurrency = UserDefaults.standard.string(forKey: "userBaseCurrencyCode")
        self.baseCurrencyCode = savedCurrency ?? CurrencyData.detectUserCurrency()
        
        self.lastUsedAccountName = UserDefaults.standard.string(forKey: "lastUsedAccountName")
    }
    
    func getBaseCurrency(from currencies: [Currency]) -> Currency? {
        return currencies.first { $0.code == baseCurrencyCode }
    }
    
    // MARK: - Account Selection Logic
    
    func getPreferredAccount(from accounts: [Account]) -> Account? {
        // Try to find last used account by name
        if let lastUsedName = lastUsedAccountName,
           let lastUsedAccount = accounts.first(where: { $0.name == lastUsedName }) {
            return lastUsedAccount
        }
        
        // Fallback to first account
        return accounts.first
    }
    
    func updateLastUsedAccount(_ account: Account) {
        lastUsedAccountName = account.name
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
