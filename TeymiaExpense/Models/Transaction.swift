import Foundation
import SwiftData

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

enum TransactionType: String, CaseIterable, Codable {
    case expense = "expense"
    case income = "income"
    case transfer = "transfer"
}
