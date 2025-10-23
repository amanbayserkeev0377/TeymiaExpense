import SwiftUI
import Foundation

// MARK: - Transaction Display Extensions
extension Transaction {
    
    /// Universal color for transaction type across the app
    var typeColor: Color {
        switch type {
        case .income:
            return Color("IncomeColor")
        case .expense:
            return Color("ExpenseColor")
        case .transfer:
            return Color("TransferColor")
        }
    }
    
    func formattedAmount(for account: Account? = nil) -> String {
        let currency = account?.currency ?? self.account?.currency ?? Currency(
            code: "USD",
            symbol: "$",
            name: "US Dollar",
            type: .fiat
        )
        
        let displayAmount = abs(amount)
        return CurrencyFormatter.format(displayAmount, currency: currency)
    }
    
    /// Get display title for transaction
    func displayTitle(relativeTo account: Account?) -> String {
        if type == .transfer {
            if self.account?.id == account?.id {
                return "transfer_to".localized + " \(toAccount?.name ?? "Account")"
            } else {
                return "transfer_from".localized + " \(self.account?.name ?? "Account")"
            }
        }
        return category?.name ?? "general_category".localized
    }
    
    /// Get icon name for transaction
    var displayIcon: String {
        if type == .transfer {
            return "transfer"
        }
        return category?.iconName ?? "general"
    }
}

// MARK: - TransactionType Extensions
extension TransactionType {
    
    /// Universal color for transaction type
    var color: Color {
        switch self {
        case .income:
            return Color("IncomeColor")
        case .expense:
            return Color("ExpenseColor")
        case .transfer:
            return Color("TransferColor")
        }
    }
    
    var displayName: String {
        switch self {
        case .expense: return "transaction_type_expense".localized
        case .income: return "transaction_type_income".localized
        case .transfer: return "transaction_type_transfer".localized
        }
    }
    
    var customIconName: String {
        switch self {
        case .expense: return "expense"
        case .income: return "income"
        case .transfer: return "transfer"
        }
    }
}
