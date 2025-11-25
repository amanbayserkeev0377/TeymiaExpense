import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = ""
    private var typeRawValue: String = "expense"
    var sortOrder: Int = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    
    // Computed property for enum
    var type: CategoryType {
        get { CategoryType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    init(
        name: String,
        iconName: String,
        type: CategoryType,
        sortOrder: Int,
        isDefault: Bool
    ) {
        self.name = name
        self.iconName = iconName
        self.typeRawValue = type.rawValue
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

// MARK: - Category Type

enum CategoryType: String, Codable, CaseIterable {
    case expense = "expense"
    case income = "income"
    
    var localizedName: String {
        switch self {
        case .expense: return "expense".localized
        case .income: return "income".localized
        }
    }
}

// MARK: - Create Defaults

extension Category {
    static func createDefaults(context: ModelContext) {
        // Check if categories already exist
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = (try? context.fetch(descriptor)) ?? []
        
        guard existingCategories.isEmpty else {
            print("✅ Categories already exist, skipping")
            return
        }
        
        print("📝 Creating default categories...")
        
        createExpenseCategories(context: context)
        createIncomeCategories(context: context)
        
        print("✅ Default categories created")
    }
    
    // MARK: - Expense Categories
    
    private static func createExpenseCategories(context: ModelContext) {
        let expenseCategories: [(String, String)] = [
            ("Other", "other"),
            ("Groceries", "groceries"),
            ("Cafe", "fork.knife"),
            ("Transport", "transport"),
            ("Shopping", "shopping"),
            ("Entertainment", "entertainment"),
            ("Health", "health"),
            ("Housing", "housing"),
            ("Education", "education"),
            ("Family", "family"),
        ]
        
        for (index, (name, icon)) in expenseCategories.enumerated() {
            let category = Category(
                name: name,
                iconName: icon,
                type: .expense,
                sortOrder: index,
                isDefault: true
            )
            context.insert(category)
        }
        
        print("✅ Created \(expenseCategories.count) expense categories")
    }
    
    // MARK: - Income Categories
    
    private static func createIncomeCategories(context: ModelContext) {
        let incomeCategories: [(String, String)] = [
            ("Salary", "salary"),
            ("Gift", "gift"),
            ("Bonuses", "bonuses"),
            ("Business", "business"),
            ("Investment", "investment"),
            ("Other", "other")
        ]
        
        for (index, (name, icon)) in incomeCategories.enumerated() {
            let category = Category(
                name: name,
                iconName: icon,
                type: .income,
                sortOrder: index + 100,
                isDefault: true
            )
            context.insert(category)
        }
        
        print("✅ Created \(incomeCategories.count) income categories")
    }
}
