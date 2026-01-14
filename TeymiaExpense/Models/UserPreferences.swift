import Foundation
import SwiftData
import SwiftUI

@Observable
class UserPreferences {
    @MainActor
    func setupInitialData(modelContext: ModelContext) {
        Category.createDefaults(context: modelContext)
        Account.createDefaults(context: modelContext, userCurrency: baseCurrencyCode)
    }
    
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
        guard let lastIDString = lastUsedAccountID else {
            return accounts.first
        }
        
        return accounts.first(where: { $0.id.uuidString == lastIDString })
    }
    
    func updateLastUsedAccount(_ account: Account) {
        lastUsedAccountID = account.id.uuidString
    }
    
    // MARK: - Amount Formatting

    func formatAmount(_ amount: Decimal) -> String {
        return CurrencyFormatter.format(amount, currency: baseCurrency)
    }

    func formatAmountWithoutCurrency(_ amount: Decimal, for currency: Currency? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        let currentCurrency = currency ?? baseCurrency
        
        if currentCurrency.type == .crypto {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 8
        } else {
            let isInteger = amount == NSDecimalNumber(decimal: amount).rounding(accordingToBehavior: nil).decimalValue
            formatter.minimumFractionDigits = isInteger ? 0 : 2
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: abs(amount) as NSDecimalNumber) ?? "0"
    }
}
