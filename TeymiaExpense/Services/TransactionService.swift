import SwiftUI
import SwiftData

// MARK: - Transaction Service
struct TransactionService {
    
    // MARK: - Balance Operations
    
    static func revertBalanceChanges(for transaction: Transaction) {
        if transaction.type == .transfer {
            transaction.account?.balance += abs(transaction.amount)
            let targetAmt = transaction.transferTargetAmount ?? transaction.amount
            transaction.toAccount?.balance -= abs(targetAmt)
        } else if transaction.type == .expense {
            transaction.account?.balance += abs(transaction.amount)
        } else if transaction.type == .income {
            transaction.account?.balance -= abs(transaction.amount)
        }
    }

    static func applyBalanceChanges(for transaction: Transaction) {
        if transaction.type == .transfer {
            transaction.account?.balance -= abs(transaction.amount)
            let targetAmt = transaction.transferTargetAmount ?? transaction.amount
            transaction.toAccount?.balance += abs(targetAmt)
        } else if transaction.type == .expense {
            transaction.account?.balance -= abs(transaction.amount)
        } else if transaction.type == .income {
            transaction.account?.balance += abs(transaction.amount)
        }
    }
    
    // MARK: - Save Operations
    
    static func saveExpense(
        amount: Decimal,
        account: Account,
        category: Category,
        note: String?,
        date: Date,
        context: ModelContext,
        userPreferences: UserPreferences
    ) throws {
        let cleanNote = note?.isEmpty == true ? nil : note
        let transaction = Transaction(
            amount: -abs(amount),
            note: cleanNote,
            date: date,
            type: .expense,
            category: category,
            account: account
        )
        
        account.balance -= abs(amount)
        userPreferences.updateLastUsedAccount(account)
        context.insert(transaction)
        try context.save()
    }

    static func saveIncome(
        amount: Decimal,
        account: Account,
        category: Category,
        note: String?,
        date: Date,
        context: ModelContext,
        userPreferences: UserPreferences
    ) throws {
        let cleanNote = note?.isEmpty == true ? nil : note
        let transaction = Transaction(
            amount: abs(amount),
            note: cleanNote,
            date: date,
            type: .income,
            category: category,
            account: account
        )
        
        account.balance += abs(amount)
        userPreferences.updateLastUsedAccount(account)
        context.insert(transaction)
        try context.save()
    }

    static func saveTransfer(
        amount: Decimal,
        targetAmount: Decimal,
        fromAccount: Account,
        toAccount: Account,
        note: String?,
        date: Date,
        context: ModelContext,
        userPreferences: UserPreferences
    ) throws {
        let cleanNote = note?.isEmpty == true ? nil : note
        
        let transaction = Transaction(
            amount: abs(amount),
            transferTargetAmount: abs(targetAmount),
            note: cleanNote,
            date: date,
            type: .transfer,
            account: fromAccount,
            toAccount: toAccount
        )
        
        fromAccount.balance -= abs(amount)
        toAccount.balance += abs(targetAmount)
        
        userPreferences.updateLastUsedAccount(fromAccount)
        context.insert(transaction)
        try context.save()
    }

    // MARK: - Update Operation
    
    static func updateTransaction(
        _ transaction: Transaction,
        newAmount: Decimal,
        newTargetAmount: Decimal? = nil,
        newAccount: Account?,
        newToAccount: Account?,
        newCategory: Category?,
        newNote: String?,
        newDate: Date,
        newType: TransactionType,
        context: ModelContext
    ) throws {
        revertBalanceChanges(for: transaction)
        transaction.type = newType
        transaction.amount = newType == .expense ? -abs(newAmount) : abs(newAmount)
        if newType == .transfer {
            transaction.transferTargetAmount = abs(newTargetAmount ?? newAmount)
        } else {
            transaction.transferTargetAmount = nil
        }
        
        transaction.account = newAccount
        transaction.toAccount = newToAccount
        transaction.category = newCategory
        transaction.note = newNote?.isEmpty == true ? nil : newNote
        transaction.date = newDate
        
        applyBalanceChanges(for: transaction)
        
        try context.save()
    }
    
    // MARK: - Helper Methods
    
    static func getDefaultCategory(for type: TransactionType, from categories: [Category]) -> Category? {
        switch type {
        case .income:
            return categories.first { $0.type == .income && $0.name.lowercased().contains("salary") }
                ?? categories.first { $0.type == .income }
        case .expense:
            return categories.first { $0.type == .expense && $0.name.lowercased().contains("other") }
                ?? categories.first { $0.type == .expense }
        case .transfer:
            return nil
        }
    }
}

// MARK: - Currency Formatter

struct CurrencyFormatter {
    static func format(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        configureFractionDigits(for: formatter, amount: amount, currency: currency)
        
        let numberString = formatter.string(from: abs(amount) as NSDecimalNumber) ?? "0"
        let prefix = amount < 0 ? "-" : ""
        
        return "\(prefix)\(numberString) \(currency.symbol)"
    }
    
    static func formatForEditing(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        
        return formatter.string(from: abs(amount) as NSDecimalNumber) ?? ""
    }
    
    private static func configureFractionDigits(
        for formatter: NumberFormatter,
        amount: Decimal,
        currency: Currency
    ) {
        if currency.type == .crypto {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 8
        } else {
            if amount == 0 {
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 0
            } else {
                let decimalValue = NSDecimalNumber(decimal: amount).doubleValue
                let isInteger = amount == Decimal(Int64(decimalValue))
                
                formatter.minimumFractionDigits = isInteger ? 0 : 2
                formatter.maximumFractionDigits = 2
            }
        }
    }
}
