import Foundation
import SwiftData

extension Category {
    static func createDefaults(context: ModelContext) {
        // Default expense categories with SF Symbols
        let expenseCategories = [
            ("Food", "fork.knife"),
            ("Transport", "car"),
            ("Entertainment", "gamecontroller"),
            ("Shopping", "bag"),
            ("Health", "cross.case"),
            ("Education", "book"),
            ("Bills", "doc.text"),
            ("Other", "ellipsis.circle")
        ]
        
        for (name, sfSymbol) in expenseCategories {
            let category = Category(
                name: name,
                iconName: sfSymbol,
                type: .expense,
                isDefault: true
            )
            context.insert(category)
        }
        
        // Default income categories with SF Symbols
        let incomeCategories = [
            ("Salary", "banknote"),
            ("Business", "building.2"),
            ("Investment", "chart.line.uptrend.xyaxis"),
            ("Gift", "gift"),
            ("Other", "ellipsis.circle")
        ]
        
        for (name, sfSymbol) in incomeCategories {
            let category = Category(
                name: name,
                iconName: sfSymbol,
                type: .income,
                isDefault: true
            )
            context.insert(category)
        }
    }
}
