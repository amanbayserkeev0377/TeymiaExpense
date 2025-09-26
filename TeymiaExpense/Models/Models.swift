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

// MARK: - CategoryGroup
@Model
final class CategoryGroup {
    var name: String        // "Food & Drinks", "Transport"
    var iconName: String
    var type: GroupType     // income or expense
    var sortOrder: Int
    var isDefault: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Category.categoryGroup)
    var categories: [Category] = []
    
    init(name: String, iconName: String, type: GroupType, sortOrder: Int = 0, isDefault: Bool = false) {
        self.name = name
        self.iconName = iconName
        self.type = type
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

// MARK: - Category
@Model
final class Category {
    var name: String        // "Coffee", "Restaurant", "Taxi"
    var iconName: String
    var sortOrder: Int
    var isDefault: Bool
    var createdAt: Date
    
    // Relationships
    var categoryGroup: CategoryGroup
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []
    
    init(name: String, iconName: String, categoryGroup: CategoryGroup, sortOrder: Int = 0, isDefault: Bool = false) {
        self.name = name
        self.iconName = iconName
        self.categoryGroup = categoryGroup
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

// MARK: - Account
@Model
final class Account {
    var name: String
    var balance: Decimal
    var isDefault: Bool
    var createdAt: Date
    
    var designIndex: Int
    var customIcon: String
    var designType: AccountDesignType
    
    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction] = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.toAccount)
    var incomingTransfers: [Transaction] = []
    
    var currency: Currency
    
    init(name: String, balance: Decimal, currency: Currency, isDefault: Bool = false, designIndex: Int = 0, customIcon: String = "cash", designType: AccountDesignType = .image) {
        self.name = name
        self.balance = balance
        self.currency = currency
        self.isDefault = isDefault
        self.designIndex = designIndex
        self.customIcon = customIcon
        self.designType = designType
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
    var isHidden: Bool = false
    var createdAt: Date
    
    // Relationships
    var categoryGroup: CategoryGroup?
    var category: Category?
    var account: Account?
    var toAccount: Account?
    
    init(amount: Decimal, note: String? = nil, date: Date = Date(), type: TransactionType, categoryGroup: CategoryGroup? = nil, category: Category? = nil, account: Account? = nil, toAccount: Account? = nil, isHidden: Bool = false) {
        self.amount = amount
        self.note = note
        self.date = date
        self.type = type
        self.isHidden = isHidden
        self.categoryGroup = categoryGroup
        self.category = category
        self.account = account
        self.toAccount = toAccount
        self.createdAt = Date()
    }
}

// MARK: - Enums
enum GroupType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
}

enum TransactionType: String, CaseIterable, Codable {
    case expense = "expense"
    case income = "income"
    case transfer = "transfer"
}

enum CurrencyType: String, CaseIterable, Codable {
    case fiat = "fiat"
    case crypto = "crypto"
}

enum AccountDesignType: String, CaseIterable, Codable {
    case image = "image"
    case color = "color"
}
