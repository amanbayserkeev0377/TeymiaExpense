import Foundation
import SwiftData

@Model
final class Category {
    var name: String = ""
    var iconName: String = ""
    var sortOrder: Int = 0
    var isDefault: Bool = false
    var createdAt: Date = Date()
    var categoryGroup: CategoryGroup? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    init(
        name: String,
        iconName: String,
        categoryGroup: CategoryGroup,
        sortOrder: Int = 0,
        isDefault: Bool = false
    ) {
        self.name = name
        self.iconName = iconName
        self.categoryGroup = categoryGroup
        self.sortOrder = sortOrder
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}

extension Category {
    static func createDefaults(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        let existing = (try? context.fetch(descriptor)) ?? []
        
        if !existing.isEmpty {
            return
        }
        
        let categoryGroupDescriptor = FetchDescriptor<CategoryGroup>()
        let categoryGroups = (try? context.fetch(categoryGroupDescriptor)) ?? []
        
        guard !categoryGroups.isEmpty else {
            print("Warning: No category groups found for creating categories")
            return
        }
        
        func findCategoryGroup(name: String, type: GroupType) -> CategoryGroup? {
            return categoryGroups.first { $0.name == name && $0.type == type }
        }
        
        createExpenseCategories(findCategoryGroup: findCategoryGroup, context: context)
        createIncomeCategories(findCategoryGroup: findCategoryGroup, context: context)
    }
    
    private static func createExpenseCategories(
        findCategoryGroup: (String, GroupType) -> CategoryGroup?,
        context: ModelContext
    ) {
        let categoryData: [(groupName: String, categories: [(String, String)])] = [
            ("food.drinks".localized, [
                ("delivery".localized, "delivery"),
                ("groceries".localized, "groceries"),
                ("restaurant".localized, "restaurant"),
                ("coffee".localized, "coffee"),
                ("fast.food".localized, "fast.food"),
                ("alcohol".localized, "alcohol"),
                ("lunches".localized, "lunches")
            ]),
            ("transport".localized, [
                ("taxi".localized, "taxi"),
                ("public.transport".localized, "public.transport"),
                ("fuel".localized, "fuel"),
                ("parking".localized, "parking"),
                ("repair".localized, "repair"),
                ("washing".localized, "washing")
            ]),
            ("entertainment".localized, [
                ("cinema".localized, "cinema"),
                ("events".localized, "events"),
                ("subscriptions".localized, "subscriptions"),
                ("hobbies".localized, "hobbies"),
                ("gaming".localized, "gaming"),
                ("vacation".localized, "vacation")
            ]),
            ("sports".localized, [
                ("equipment".localized, "equipment"),
                ("gym".localized, "gym"),
                ("swimming".localized, "swimming"),
                ("yoga".localized, "yoga")
            ]),
            ("shopping".localized, [
                ("clothing".localized, "clothing"),
                ("cosmetics".localized, "cosmetics"),
                ("electronics".localized, "electronics"),
                ("gifts".localized, "gifts"),
                ("marketplaces".localized, "marketplaces")
            ]),
            ("health".localized, [
                ("dental".localized, "dental"),
                ("hospital".localized, "hospital"),
                ("pharmacy".localized, "pharmacy"),
                ("checkups".localized, "checkups"),
                ("therapy".localized, "therapy")
            ]),
            ("housing".localized, [
                ("rent".localized, "rent"),
                ("furniture".localized, "furniture"),
                ("home.maintenance".localized, "home.maintenance"),
                ("internet".localized, "internet"),
                ("telephone".localized, "telephone"),
                ("water".localized, "water"),
                ("electricity".localized, "electricity"),
                ("gas".localized, "gas"),
                ("tv.cable".localized, "tv.cable")
            ]),
            ("travel".localized, [
                ("flights".localized, "flights"),
                ("visadocument".localized, "visadocument"),
                ("hotel".localized, "hotel"),
                ("tours".localized, "tours")
            ]),
            ("education".localized, [
                ("books".localized, "books"),
                ("courses".localized, "courses"),
                ("student.loan".localized, "student.loan"),
                ("materials".localized, "materials")
            ]),
            ("pet".localized, [
                ("pet.food".localized, "pet.food"),
                ("veterinary".localized, "veterinary"),
                ("toys.accessories".localized, "toys.accessories")
            ]),
            ("child".localized, [
                ("kids.clothes".localized, "kids.clothes"),
                ("school.supplies".localized, "school.supplies"),
                ("kids.food".localized, "kids.food"),
                ("kids.healthcare".localized, "kids.healthcare"),
                ("toys.entertainment".localized, "toys.entertainment"),
                ("gifts.parties".localized, "gifts.parties")
            ]),
            ("other".localized, [
                ("general".localized, "general")
            ])
        ]
        
        for (groupName, categories) in categoryData {
            guard let categoryGroup = findCategoryGroup(groupName, .expense) else {
                print("Warning: CategoryGroup '\(groupName)' not found for expense categories")
                continue
            }
            
            for (index, (categoryName, iconName)) in categories.enumerated() {
                let category = Category(
                    name: categoryName,
                    iconName: iconName,
                    categoryGroup: categoryGroup,
                    sortOrder: index,
                    isDefault: true
                )
                context.insert(category)
            }
        }
    }
    
    private static func createIncomeCategories(
        findCategoryGroup: (String, GroupType) -> CategoryGroup?,
        context: ModelContext
    ) {
        let categoryData: [(groupName: String, categories: [(String, String)])] = [
            ("salary".localized, [
                ("monthly.salary".localized, "monthly.salary"),
                ("overtime".localized, "overtime"),
                ("bonus".localized, "bonus")
            ]),
            ("gift".localized, [
                ("birthday.gift".localized, "birthday.gift"),
                ("event.gift".localized, "event.gift")
            ]),
            ("bonuses".localized, [
                ("performance.bonus".localized, "performance.bonus"),
                ("yearend.bonus".localized, "yearend.bonus"),
                ("commission".localized, "commission")
            ]),
            ("business".localized, [
                ("freelance".localized, "freelance"),
                ("consulting".localized, "consulting"),
                ("business.revenue".localized, "business.revenue")
            ]),
            ("investment".localized, [
                ("dividends".localized, "dividends"),
                ("interest".localized, "interest"),
                ("crypto".localized, "crypto"),
                ("rental.income".localized, "rental.income")
            ]),
            ("other".localized, [
                ("refund".localized, "refund"),
                ("cashback".localized, "cashback")
            ])
        ]
        
        for (groupName, categories) in categoryData {
            guard let categoryGroup = findCategoryGroup(groupName, .income) else {
                print("Warning: CategoryGroup '\(groupName)' not found for income categories")
                continue
            }
            
            for (index, (categoryName, iconName)) in categories.enumerated() {
                let category = Category(
                    name: categoryName,
                    iconName: iconName,
                    categoryGroup: categoryGroup,
                    sortOrder: index,
                    isDefault: true
                )
                context.insert(category)
            }
        }
    }
}
