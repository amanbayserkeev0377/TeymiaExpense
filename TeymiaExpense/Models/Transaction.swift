import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    var amount: Decimal = 0
    var transferTargetAmount: Decimal? = nil
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
        transferTargetAmount: Decimal? = nil,
        note: String? = nil,
        date: Date = Date(),
        type: TransactionType,
        category: Category? = nil,
        account: Account? = nil,
        toAccount: Account? = nil
    ) {
        self.amount = amount
        self.transferTargetAmount = transferTargetAmount
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
    
    var color: Color {
        switch self {
        case .income: return .income
        case .expense: return .primary
        case .transfer: return .transfer
        }
    }
    
    var displayName: String {
        switch self {
        case .expense: return "expense".localized
        case .income: return "income".localized
        case .transfer: return "transfer".localized
        }
    }
}

extension Transaction {
    
    var typeColor: Color {
        type.color
    }
    
    var displayIcon: String {
        type == .transfer ? "transfer" : (category?.iconName ?? "questionmark.circle")
    }
    
    func displayTitle() -> String {
        if type == .transfer {
            return "\(account?.name ?? "...") → \(toAccount?.name ?? "...")"
        }
        return category?.name ?? "unrecognized".localized
    }
    
    func formattedAmount(for account: Account? = nil) -> String {
        let displayAmount = if let acc = account {
            amountForAccount(acc)
        } else {
            amount
        }
        
        let currency = account?.currency ?? self.account?.currency ?? .defaultUSD
        return CurrencyFormatter.format(displayAmount, currency: currency)
    }
    
    func amountForAccount(_ currentAccount: Account) -> Decimal {
        switch type {
        case .expense:
            return -abs(amount)
        case .income:
            return abs(amount)
        case .transfer:
            if account?.id == currentAccount.id {
                return -abs(amount)
            } else if toAccount?.id == currentAccount.id {
                return abs(transferTargetAmount ?? amount)
            }
            return 0
        }
    }
}
