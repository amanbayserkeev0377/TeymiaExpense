import Foundation
import SwiftData

extension Category {
    static func createDefaults(context: ModelContext) {
        let expenseCategories = [
            ("other".localized, "other"), // default category
            ("food".localized, "food"),
            ("transport".localized, "transport"),
            ("entertainment".localized, "entertainment"),
            ("sports".localized, "sports"),
            ("shopping".localized, "shopping"),
            ("health".localized, "health"),
            ("vacation".localized, "vacation"),
            ("travel".localized, "travel"),
            ("education".localized, "education"),
            ("pet".localized, "pet"),
            ("rent".localized, "rent"),
            ("child".localized, "child"),
            ("groceries".localized, "groceries"),
            ("utilities".localized, "utilities"),
        ]
        
        for (index, (name, iconName)) in expenseCategories.enumerated() {
            let category = Category(
                name: name,
                iconName: iconName,
                type: .expense,
                isDefault: true,
                sortOrder: index
            )
            context.insert(category)
        }
        
        // Default income categories
        let incomeCategories = [
            ("other".localized, "other"), // default category
            ("salary".localized, "salary"),
            ("bonuses".localized, "bonuses"),
            ("business".localized, "business"),
            ("investment".localized, "investment"),
            ("gift".localized, "gift"),
        ]
        
        for (name, iconName) in incomeCategories {
            let category = Category(
                name: name,
                iconName: iconName,
                type: .income,
                isDefault: true
            )
            context.insert(category)
        }
    }
}
