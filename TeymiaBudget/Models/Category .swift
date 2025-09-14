import Foundation
import SwiftData

extension Category {
    static func createDefaults(context: ModelContext) {
        let expenseCategories = [
            ("food".localized, "food"),
            ("transport".localized, "transport"),
            ("entertainment".localized, "entertainment"),
            ("shopping".localized, "shopping"),
            ("health".localized, "health"),
            ("education".localized, "education"),
            ("other".localized, "other") // default category
        ]
        
        for (name, iconName) in expenseCategories {
            let category = Category(
                name: name,
                iconName: iconName,
                type: .expense,
                isDefault: true
            )
            context.insert(category)
        }
        
        // Default income categories
        let incomeCategories = [
            ("salary".localized, "salary"),
            ("business".localized, "business"),
            ("investment".localized, "investment"),
            ("gift".localized, "gift"),
            ("other".localized, "other") // default category
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
