import SwiftUI
import SwiftData

// MARK: - Core Logic (Service)
struct TransactionService {
    static func revertBalanceChanges(for transaction: Transaction) {
            transaction.account?.balance -= transaction.amount
            
            if transaction.type == .transfer {
                transaction.toAccount?.balance -= transaction.amount
            }
        }

        static func applyBalanceChanges(for transaction: Transaction) {
            transaction.account?.balance += transaction.amount
            
            if transaction.type == .transfer {
                transaction.toAccount?.balance += transaction.amount
            }
        }
    
    static func saveExpense(amount: Decimal, account: Account, category: Category, note: String?, date: Date, context: ModelContext, userPreferences: UserPreferences) throws {
        let transaction = Transaction(amount: -abs(amount), note: note?.isEmpty == true ? nil : note, date: date, type: .expense, category: category, account: account)
        account.balance -= abs(amount)
        userPreferences.updateLastUsedAccount(account)
        context.insert(transaction)
        try context.save()
    }

    static func saveIncome(amount: Decimal, account: Account, category: Category, note: String?, date: Date, context: ModelContext, userPreferences: UserPreferences) throws {
        let transaction = Transaction(amount: abs(amount), note: note?.isEmpty == true ? nil : note, date: date, type: .income, category: category, account: account)
        account.balance += abs(amount)
        userPreferences.updateLastUsedAccount(account)
        context.insert(transaction)
        try context.save()
    }

    static func saveTransfer(amount: Decimal, fromAccount: Account, toAccount: Account, note: String?, date: Date, context: ModelContext, userPreferences: UserPreferences) throws {
        let transaction = Transaction(amount: abs(amount), note: note?.isEmpty == true ? nil : note, date: date, type: .transfer, account: fromAccount, toAccount: toAccount)
        fromAccount.balance -= abs(amount)
        toAccount.balance += abs(amount)
        userPreferences.updateLastUsedAccount(fromAccount)
        context.insert(transaction)
        try context.save()
    }

    static func updateTransaction(_ transaction: Transaction, newAmount: Decimal, newAccount: Account?, newToAccount: Account?, newCategory: Category?, newNote: String?, newDate: Date, newType: TransactionType, context: ModelContext) throws {
        // Откат старого баланса
        transaction.account?.balance -= transaction.amount
        if transaction.type == .transfer { transaction.toAccount?.balance -= transaction.amount }
        
        // Обновление данных (сохраняем знак в зависимости от типа)
        transaction.type = newType
        transaction.amount = (newType == .expense) ? -abs(newAmount) : abs(newAmount)
        transaction.account = newAccount
        transaction.toAccount = newToAccount
        transaction.category = newCategory
        transaction.note = newNote?.isEmpty == true ? nil : newNote
        transaction.date = newDate
        
        // Применение нового баланса
        transaction.account?.balance += transaction.amount
        if transaction.type == .transfer { transaction.toAccount?.balance += transaction.amount }
        
        try context.save()
    }
    
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

// MARK: - UI & Display Extensions
extension Transaction {
    var typeColor: Color {
        switch type {
        case .income:   return Color("IncomeColor")
        case .expense:  return .primary
        case .transfer: return Color("TransferColor")
        }
    }
    
    func formattedAmount(for account: Account? = nil) -> String {
        let currency = account?.currency ?? self.account?.currency ?? .defaultUSD
        // Форматируем только абсолютное значение (без знака)
        return CurrencyFormatter.format(abs(amount), currency: currency)
    }
    
    var displayIcon: String {
        type == .transfer ? "transfer" : (category?.iconName ?? "questionmark.circle")
    }
    
    func displayTitle() -> String {
        if type == .transfer {
            return "\(account?.name ?? "...") → \(toAccount?.name ?? "...")"
        }
        return category?.name ?? ""
    }
}

// MARK: - Shared Formatter
struct CurrencyFormatter {
    static func format(_ amount: Decimal, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        
        // Настройка дробной части
        if amount == 0 {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        } else if abs(amount) < 1 {
            // Для маленьких значений (крипта) показываем до 8 знаков
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
        } else {
            // Для обычных денег: если целое — 0 знаков, если есть копейки — 2 знака
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
        }
        
        let numberString = formatter.string(from: abs(amount) as NSDecimalNumber) ?? "0"
        return "\(numberString) \(currency.symbol)"
    }
}
