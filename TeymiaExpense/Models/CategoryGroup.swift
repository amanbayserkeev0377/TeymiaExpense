import Foundation
import SwiftData

@Model
final class CategoryGroup {
    var name: String = ""
    var iconName: String = ""
    private var typeRawValue: String = "expense"
    var sortOrder: Int = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    
    var type: GroupType {
        get { GroupType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \Category.categoryGroup)
    var categories: [Category]? = []
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.categoryGroup)
    var transactions: [Transaction]? = []
    
    init(
        name: String,
        iconName: String,
        type: GroupType,
        sortOrder: Int = 0,
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

extension CategoryGroup {
    static func createDefaults(context: ModelContext) {
        let descriptor = FetchDescriptor<CategoryGroup>()
        let existing = (try? context.fetch(descriptor)) ?? []
        
        if !existing.isEmpty {
            return
        }
        
        let expenseGroups = [
            ("other".localized, "other", 0),
            ("food.drinks".localized, "food.drinks", 1),
            ("transport".localized, "transport", 2),
            ("entertainment".localized, "entertainment", 3),
            ("sports".localized, "sports", 4),
            ("shopping".localized, "shopping", 5),
            ("health".localized, "health", 6),
            ("housing".localized, "housing", 7),
            ("travel".localized, "travel", 8),
            ("education".localized, "education", 9),
            ("pet".localized, "pet", 10),
            ("child".localized, "child", 11)
        ]
        
        for (name, iconName, sortOrder) in expenseGroups {
            let categoryGroup = CategoryGroup(
                name: name,
                iconName: iconName,
                type: .expense,
                sortOrder: sortOrder,
                isDefault: true
            )
            context.insert(categoryGroup)
        }
        
        let incomeGroups = [
            ("salary".localized, "salary", 0),
            ("gift".localized, "gift", 1),
            ("bonuses".localized, "bonuses", 2),
            ("business".localized, "business", 3),
            ("investment".localized, "investment", 4),
            ("other".localized, "other", 5)
        ]
        
        for (name, iconName, sortOrder) in incomeGroups {
            let categoryGroup = CategoryGroup(
                name: name,
                iconName: iconName,
                type: .income,
                sortOrder: sortOrder,
                isDefault: true
            )
            context.insert(categoryGroup)
        }
    }
}

enum TransferError: Error {
    case importNotSupported
}

enum GroupType: String, CaseIterable, Codable {
    case income = "income"
    case expense = "expense"
}
