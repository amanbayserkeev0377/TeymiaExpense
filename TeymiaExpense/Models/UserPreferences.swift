import Foundation
import SwiftUI

@Observable
class UserPreferences {
    var baseCurrencyCode: String {
        didSet {
            UserDefaults.standard.set(baseCurrencyCode, forKey: "userBaseCurrencyCode")
        }
    }
    
    var lastUsedAccountID: String? {
        didSet {
            UserDefaults.standard.set(lastUsedAccountID, forKey: "lastUsedAccountID")
        }
    }
    
    init() {
        let savedCurrency = UserDefaults.standard.string(forKey: "userBaseCurrencyCode")
        self.baseCurrencyCode = savedCurrency ?? CurrencyService.detectUserCurrency()
        
        self.lastUsedAccountID = UserDefaults.standard.string(forKey: "lastUsedAccountID")
    }
    
    var baseCurrency: Currency {
        CurrencyService.getCurrency(for: baseCurrencyCode)
    }
    
    // MARK: - Account Management
    
    func getPreferredAccount(from accounts: [Account]) -> Account? {
            if let lastID = lastUsedAccountID,
               let lastAccount = accounts.first(where: { $0.id.uuidString == lastID }) {
                return lastAccount
            }
            
            return accounts.first
        }
    
    func updateLastUsedAccount(_ account: Account) {
            lastUsedAccountID = account.id.uuidString
        }
    
    // MARK: - Amount Formatting
    func formatAmount(_ amount: Decimal) -> String {
            return CurrencyFormatter.format(abs(amount), currency: baseCurrency)
        }

    func formatAmountWithoutCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        if abs(amount) > 0 && abs(amount) < 1 {
            formatter.maximumFractionDigits = 8
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        formatter.minimumFractionDigits = 0
        return formatter.string(from: abs(amount) as NSDecimalNumber) ?? "0"
    }
}
