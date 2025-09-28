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
        self.baseCurrencyCode = savedCurrency ?? CurrencyService.detectUserCurrency()
        
        self.lastUsedAccountName = UserDefaults.standard.string(forKey: "lastUsedAccountName")
    }
    
    func getBaseCurrency(from currencies: [Currency]) -> Currency? {
        return currencies.first { $0.code == baseCurrencyCode }
    }
    
    // MARK: - Account Management
    
    func getPreferredAccount(from accounts: [Account]) -> Account? {
        // Try to find last used account by name
        if let lastUsedName = lastUsedAccountName,
           let lastUsedAccount = accounts.first(where: { $0.name == lastUsedName }) {
            return lastUsedAccount
        }
        
        // Fallback to default account
        if let defaultAccount = accounts.first(where: { $0.isDefault }) {
            return defaultAccount
        }
        
        // Ultimate fallback to first account
        return accounts.first
    }
    
    func updateLastUsedAccount(_ account: Account) {
        lastUsedAccountName = account.name
    }
    
    // MARK: - Amount Formatting
    
    func formatAmount(_ amount: Decimal, currencies: [Currency]) -> String {
        let currency = currencies.first { $0.code == baseCurrencyCode } ?? currencies.first
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency?.code ?? "USD"
        formatter.currencySymbol = currency?.symbol ?? "$"
        
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currency?.symbol ?? "$")0.00"
    }
}
