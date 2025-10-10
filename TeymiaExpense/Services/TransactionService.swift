import Foundation
import SwiftData

struct TransactionService {
    
    // MARK: - Save Methods
    
    static func saveExpense(
        amount: Decimal,
        account: Account,
        category: Category,
        note: String?,
        date: Date,
        context: ModelContext,
        userPreferences: UserPreferences
    ) throws {
        let transaction = Transaction(
            amount: -amount,
            note: note?.isEmpty == true ? nil : note,
            date: date,
            type: .expense,
            categoryGroup: category.categoryGroup,
            category: category,
            account: account
        )
        
        account.balance -= amount
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
        let transaction = Transaction(
            amount: amount,
            note: note?.isEmpty == true ? nil : note,
            date: date,
            type: .income,
            categoryGroup: category.categoryGroup,
            category: category,
            account: account
        )
        
        account.balance += amount
        userPreferences.updateLastUsedAccount(account)
        context.insert(transaction)
        try context.save()
    }
    
    static func saveTransfer(
        amount: Decimal,
        fromAccount: Account,
        toAccount: Account,
        note: String?,
        date: Date,
        context: ModelContext,
        userPreferences: UserPreferences
    ) throws {
        let transaction = Transaction(
            amount: amount,
            note: note?.isEmpty == true ? nil : note,
            date: date,
            type: .transfer,
            categoryGroup: nil,
            category: nil,
            account: fromAccount,
            toAccount: toAccount
        )
        
        fromAccount.balance -= amount
        toAccount.balance += amount
        
        userPreferences.updateLastUsedAccount(fromAccount)
        context.insert(transaction)
        try context.save()
    }
    
    // MARK: - Update Methods
    
    static func updateTransaction(
        _ transaction: Transaction,
        newAmount: Decimal,
        newAccount: Account?,
        newToAccount: Account?,
        newCategory: Category?,
        newNote: String?,
        newDate: Date,
        newType: TransactionType,
        context: ModelContext
    ) throws {
        // Revert original balance changes
        revertBalanceChanges(for: transaction)
        
        // Update transaction properties
        transaction.amount = newAmount
        transaction.note = newNote?.isEmpty == true ? nil : newNote
        transaction.date = newDate
        transaction.type = newType
        transaction.account = newAccount
        transaction.toAccount = newToAccount
        transaction.category = newCategory
        transaction.categoryGroup = newCategory?.categoryGroup
        
        // Apply new balance changes
        applyBalanceChanges(for: transaction)
        
        try context.save()
    }
    
    // MARK: - Helper Methods
    
    static func getDefaultCategory(for type: TransactionType, from categories: [Category]) -> Category? {
        switch type {
        case .income:
            return categories.first { category in
                category.categoryGroup?.type == .income &&
                (category.categoryGroup?.name.lowercased().contains("salary") ?? false) &&
                category.name.lowercased().contains("monthly.salary")
            } ?? categories.first { category in
                category.categoryGroup?.type == .income &&
                (category.categoryGroup?.name.lowercased().contains("salary") ?? false)
            } ?? categories.first { $0.categoryGroup?.type == .income }
            
        case .expense:
            return categories.first { category in
                category.categoryGroup?.type == .expense &&
                (category.categoryGroup?.name.lowercased().contains("other") ?? false) &&
                category.name.lowercased().contains("general")
            } ?? categories.first { category in
                category.categoryGroup?.type == .expense &&
                (category.categoryGroup?.name.lowercased().contains("other") ?? false)
            } ?? categories.first { $0.categoryGroup?.type == .expense }
            
        case .transfer:
            return nil
        }
    }
    
    // MARK: - Balance Management
    
    static func revertBalanceChanges(for transaction: Transaction) {
        switch transaction.type {
        case .expense:
            transaction.account?.balance += abs(transaction.amount)
        case .income:
            transaction.account?.balance -= abs(transaction.amount)
        case .transfer:
            transaction.account?.balance += abs(transaction.amount)
            transaction.toAccount?.balance -= abs(transaction.amount)
        }
    }
    
    // MARK: - Private Methods
    
    private static func applyBalanceChanges(for transaction: Transaction) {
        switch transaction.type {
        case .expense:
            transaction.account?.balance -= abs(transaction.amount)
        case .income:
            transaction.account?.balance += abs(transaction.amount)
        case .transfer:
            transaction.account?.balance -= abs(transaction.amount)
            transaction.toAccount?.balance += abs(transaction.amount)
        }
    }
}

// MARK: - Transaction Service Error
enum TransactionServiceError: LocalizedError {
    case invalidAmount
    case missingRequiredFields
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount entered"
        case .missingRequiredFields:
            return "Missing required fields"
        }
    }
}
