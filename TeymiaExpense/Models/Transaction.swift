import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Decimal = 0
    var note: String? = nil
    var date: Date = Date()
    private var typeRawValue: String = "expense"
    var createdAt: Date = Date()
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    var category: Category? = nil
    var account: Account? = nil
    var toAccount: Account? = nil
    
    init(
        amount: Decimal,
        note: String? = nil,
        date: Date = Date(),
        type: TransactionType,
        category: Category? = nil,
        account: Account? = nil,
        toAccount: Account? = nil
    ) {
        self.amount = amount
        self.note = note
        self.date = date
        self.typeRawValue = type.rawValue
        self.category = category
        self.account = account
        self.toAccount = toAccount
        self.createdAt = Date()
    }
}

enum TransactionType: String, CaseIterable, Codable, Hashable {
    case expense = "expense"
    case income = "income"
    case transfer = "transfer"
}

extension Transaction {
    
    func displayTitle(relativeTo currentAccount: Account? = nil) -> String {
        if type == .transfer {
            let fromName = self.account?.name ?? "..."
            let toName = self.toAccount?.name ?? "..."
            return "\(fromName) → \(toName)"
        }
        
        return category?.name ?? "unrecognized".localized
    }
    
    func amountForAccount(_ currentAccount: Account) -> Decimal {
            if type == .transfer {
                if account?.id == currentAccount.id {
                    return -amount
                }
                else if toAccount?.id == currentAccount.id {
                    return amount
                }
            }
            return amount
        }
}

extension TransactionType {
    var displayName: String {
        switch self {
        case .expense: return "expense".localized
        case .income: return "income".localized
        case .transfer: return "transfer".localized
        }
    }
}
