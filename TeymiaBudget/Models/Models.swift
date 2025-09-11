import Foundation
import SwiftUI
import SwiftData

// MARK: - Currency
@Model
final class Currency {
    var code: String // USD, EUR, KGS, BTC, ETH, etc.
    var symbol: String // $, €, сом, ₿, Ξ, etc.
    var name: String // US Dollar, Euro, Bitcoin, etc.
    var type: CurrencyType // fiat or crypto
    var isDefault: Bool
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \Account.currency)
    var accounts: [Account] = []
    
    init(code: String, symbol: String, name: String, type: CurrencyType, isDefault: Bool = false) {
        self.code = code
        self.symbol = symbol
        self.name = name
        self.type = type
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

// MARK: - Category
@Model
final class Category {
    var name: String
    var iconName: String
    var type: CategoryType
    var isDefault: Bool
    var createdAt: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Budget.category)
    var budgets: [Budget] = []
    
    init(name: String, iconName: String, type: CategoryType, isDefault: Bool = false) {
        self.name = name
        self.iconName = iconName
        self.type = type
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

// MARK: - Account
@Model
final class Account {
    var name: String
    var type: AccountType
    var balance: Decimal
    var isDefault: Bool
    var createdAt: Date
    
    // Кастомизация карточки
    var customColorHex: String?
    var customIcon: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction] = []
    
    var currency: Currency
    
    init(name: String, type: AccountType, balance: Decimal, currency: Currency, isDefault: Bool = false, customColorHex: String? = nil, customIcon: String? = nil) {
        self.name = name
        self.type = type
        self.balance = balance
        self.currency = currency
        self.isDefault = isDefault
        self.customColorHex = customColorHex
        self.customIcon = customIcon
        self.createdAt = Date()
    }
}

// MARK: - Transaction
@Model
final class Transaction {
    var amount: Decimal
    var note: String?
    var date: Date
    var type: TransactionType
    var createdAt: Date
    
    // Relationships
    var category: Category?
    var account: Account?
    
    init(amount: Decimal, note: String? = nil, date: Date = Date(), type: TransactionType, category: Category? = nil, account: Account? = nil) {
        self.amount = amount
        self.note = note
        self.date = date
        self.type = type
        self.category = category
        self.account = account
        self.createdAt = Date()
    }
}

// MARK: - Budget
@Model
final class Budget {
    var name: String
    var limitAmount: Decimal
    var spentAmount: Decimal
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var createdAt: Date
    
    // Relationships
    var category: Category?
    
    init(name: String, limitAmount: Decimal, period: BudgetPeriod, category: Category? = nil) {
        // Calculate dates first
        let calendar = Calendar.current
        let now = Date()
        
        let calculatedStartDate: Date
        let calculatedEndDate: Date
        
        switch period {
        case .weekly:
            calculatedStartDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            calculatedEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: calculatedStartDate) ?? now
        case .monthly:
            calculatedStartDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
            calculatedEndDate = calendar.date(byAdding: .month, value: 1, to: calculatedStartDate) ?? now
        case .yearly:
            calculatedStartDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
            calculatedEndDate = calendar.date(byAdding: .year, value: 1, to: calculatedStartDate) ?? now
        }
        
        // Initialize all properties
        self.name = name
        self.limitAmount = limitAmount
        self.spentAmount = 0
        self.period = period
        self.startDate = calculatedStartDate
        self.endDate = calculatedEndDate
        self.category = category
        self.isActive = true
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum CategoryType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
}

enum TransactionType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
}

enum AccountType: String, CaseIterable, Codable {
    case cash = "cash"
    case bankAccount = "bank_account"
    case creditCard = "credit.card"
    case savings = "savings"
}

enum BudgetPeriod: String, CaseIterable, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
}

enum CurrencyType: String, CaseIterable, Codable {
    case fiat = "fiat"
    case crypto = "crypto"
}
