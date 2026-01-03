import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = ""
    private var typeRawValue: String = "expense"
    var sortOrder: Int = 0
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
    ) {
        self.name = name
        self.iconName = iconName
        self.typeRawValue = type.rawValue
        self.sortOrder = sortOrder
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
