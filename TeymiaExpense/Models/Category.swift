import Foundation
import SwiftData
import SwiftUI

@Model
final class Category: Hashable {
    /*
     NOTE ON SYNC STRATEGY:
     We use a String 'id' instead of a raw UUID object to maintain consistency across devices.
     For default categories, we use hardcoded (deterministic) UUID strings.
     This prevents duplicate categories when a user signs in on a new device;
     CloudKit will see the same ID and merge the records instead of creating new ones.
    */
    var id: String = UUID().uuidString
    var name: String = ""
    var iconName: String = ""
    private var typeRawValue: String = "expense"
    var sortOrder: Int = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    var hexColor: String?
    
    private var iconColorRawValue: String = "gray"
    
    var type: CategoryType {
        get { CategoryType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    var iconColor: IconColor {
        get { IconColor(rawValue: iconColorRawValue) ?? .color1 }
        set { iconColorRawValue = newValue.rawValue }
    }
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    @Transient
    var actualColor: Color {
        if let hex = hexColor {
            return Color(hex: hex)
        }
        return iconColor.color
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        iconName: String,
        type: CategoryType,
        iconColor: IconColor = .color1,
        hexColor: String? = nil,
        sortOrder: Int,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.typeRawValue = type.rawValue
        self.iconColorRawValue = iconColor.rawValue
        self.hexColor = hexColor
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
    /// Creates a set of predefined categories for new users.
    /// Uses static UUIDs to ensure that categories are unique across the user's iCloud account,
    /// preventing "Race Condition" duplicates during initial CloudKit sync.
    @MainActor
    static func createDefaults(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = (try? context.fetch(descriptor)) ?? []
        
        // Skip if default set is already present (e.g., 10 expenses + 6 incomes)
        if existingCategories.count >= 16 {
            print("Default categories already present. Skipping.")
            return
        }
        
        print("Creating default categories with deterministic IDs...")
        
        // EXPENSES: Fixed UUIDs to avoid duplicates during sync
        let expenseCategories: [(id: String, name: String, icon: String, color: IconColor)] = [
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A1", "other".localized, "other", .color1),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A2", "groceries".localized, "groceries", .color5),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A3", "cafe".localized, "fork.knife", .color7),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A4", "transport".localized, "transport", .color14),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A5", "shopping".localized, "shopping", .color3),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A6", "entertainment".localized, "cinema", .color12),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A7", "health".localized, "health", .color8),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A8", "housing".localized, "housing", .color2),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5A9", "education".localized, "education", .color6),
            ("E1C2B3A4-1234-4567-890A-B1C2D3E4F5B1", "family".localized, "family", .color11)
        ]
        
        for (index, item) in expenseCategories.enumerated() {
            // Check local DB for ID before inserting to avoid duplicate context entries
            if !existingCategories.contains(where: { $0.id == item.id }) {
                let category = Category(
                    id: item.id,
                    name: item.name,
                    iconName: item.icon,
                    type: .expense,
                    iconColor: item.color,
                    sortOrder: index,
                    isDefault: true
                )
                context.insert(category)
            }
        }
        
        // INCOME: Fixed UUIDs to avoid duplicates during sync
        let incomeCategories: [(id: String, name: String, icon: String, color: IconColor)] = [
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F1", "salary".localized, "salary", .color5),
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F2", "gift".localized, "gift", .color8),
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F3", "bonuses".localized, "bonuses", .color3),
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F4", "business".localized, "business", .color12),
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F5", "investment".localized, "investment", .color6),
            ("I1D2C3B4-5678-4321-9876-A1B2C3D4E5F6", "other".localized, "other", .color1)
        ]
        
        for (index, item) in incomeCategories.enumerated() {
            if !existingCategories.contains(where: { $0.id == item.id }) {
                let category = Category(
                    id: item.id,
                    name: item.name,
                    iconName: item.icon,
                    type: .income,
                    iconColor: item.color,
                    sortOrder: index + 100,
                    isDefault: true
                )
                context.insert(category)
            }
        }
        
        try? context.save()
    }
}
