import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Decimal = 0
    var note: String? = nil
    var date: Date = Date()
    private var typeRawValue: String = "expense"
    var isHidden: Bool = false
    var createdAt: Date = Date()
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    var categoryGroup: CategoryGroup? = nil
    var category: Category? = nil
    var account: Account? = nil
    var toAccount: Account? = nil
    
    init(
        amount: Decimal,
        note: String? = nil,
        date: Date = Date(),
        type: TransactionType,
        categoryGroup: CategoryGroup? = nil,
        category: Category? = nil,
        account: Account? = nil,
        toAccount: Account? = nil,
        isHidden: Bool = false
    ) {
        self.amount = amount
        self.note = note
        self.date = date
        self.typeRawValue = type.rawValue
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
