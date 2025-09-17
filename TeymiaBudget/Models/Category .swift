import Foundation
import SwiftData

extension Category {
    static func createDefaults(context: ModelContext) {
        let expenseCategories = [
            ("other".localized, "other", 0), // default category
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
        
        for (name, iconName, sortOrder) in expenseCategories {
            let category = Category(
                name: name,
                iconName: iconName,
                type: .expense,
                sortOrder: sortOrder,
                isDefault: true
            )
            context.insert(category)
        }
        
        // Default income categories
        let incomeCategories = [
            ("salary".localized, "salary", 0), // default category
            ("gift".localized, "gift", 1),
            ("bonuses".localized, "bonuses", 2),
            ("business".localized, "business", 3),
            ("investment".localized, "investment", 4),
        ]
        
        for (name, iconName, sortOrder) in incomeCategories {
            let category = Category(
                name: name,
                iconName: iconName,
                type: .income,
                sortOrder: sortOrder,
                isDefault: true
            )
            context.insert(category)
        }
    }
}
