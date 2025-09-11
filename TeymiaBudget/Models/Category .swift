import Foundation
import SwiftData

extension Category {
    static func createDefaults(context: ModelContext) {
        // Default expense categories - кастомные иконки из Assets
        let expenseCategories = [
            ("Food", "food"),
            ("Transport", "transport"),
            ("Entertainment", "entertainment"),
            ("Shopping", "shopping"),
            ("Health", "health"),
            ("Education", "education"),
            ("Bills", "bills"),
            ("Other", "other")
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
            ("Salary", "salary"),
            ("Business", "business"),
            ("Investment", "investment"),
            ("Gift", "gift"),
            ("Other", "other")
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
