import Foundation
import SwiftData

@Model
final class Category {
    var name: String = ""
    var iconName: String = ""
    var typeRawValue: String = "expense"
    var sortOrder: Int = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    var type: CategoryType {
        get { CategoryType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(
        name: String,
        iconName: String,
        type: CategoryType,
        sortOrder: Int,
        isDefault: Bool = false
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

// MARK: - Initial Data Logic
extension Category {
    @MainActor
    static func createDefaults(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        guard (try? context.fetchCount(descriptor)) == 0 else {
            print("✅ Categories already exist, skipping creation.")
            return
        }
        
        print("📝 Creating default categories")
        
        // 2. Твои кастомные категории расходов
        let expenseCategories: [(String, String)] = [
            ("other".localized, "other"),
            ("groceries".localized, "groceries"),
            ("cafe".localized, "fork.knife"),
            ("transport".localized, "transport"),
            ("shopping".localized, "shopping"),
            ("entertainment".localized, "cinema"),
            ("health".localized, "health"),
            ("housing".localized, "housing"),
            ("education".localized, "education"),
            ("family".localized, "family")
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
        
        // 3. Твои кастомные категории доходов
        let incomeCategories: [(String, String)] = [
            ("salary".localized, "salary"),
            ("gift".localized, "gift"),
            ("bonuses".localized, "bonuses"),
            ("business".localized, "business"),
            ("investment".localized, "investment"),
            ("other".localized, "other")
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
        
        // 4. Сохраняем немедленно, чтобы другие части приложения увидели данные
        do {
            try context.save()
            print("✅ Successfully created all default categories.")
        } catch {
            print("❌ Failed to save default categories: \(error)")
        }
    }
}
