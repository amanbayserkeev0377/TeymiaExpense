import Foundation
import SwiftData

extension Subcategory {
    static func createDefaults(context: ModelContext) {
        // Получаем созданные категории
        let categoryDescriptor = FetchDescriptor<Category>()
        let categories = (try? context.fetch(categoryDescriptor)) ?? []
        
        guard !categories.isEmpty else {
            print("Warning: No categories found for creating subcategories")
            return
        }
        
        // Helper для поиска категории
        func findCategory(name: String, type: CategoryType) -> Category? {
            return categories.first { $0.name == name && $0.type == type }
        }
        
        createExpenseSubcategories(findCategory: findCategory, context: context)
        createIncomeSubcategories(findCategory: findCategory, context: context)
    }
    
    private static func createExpenseSubcategories(findCategory: (String, CategoryType) -> Category?, context: ModelContext) {
        let subcategoryData: [(categoryName: String, subcategories: [(String, String)])] = [
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
                ("yoga".localized, "yoga"),
                ("fitness".localized, "fitness")
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
                ("visa".localized, "visa"),
                ("souvenirs".localized, "souvenirs"),
                ("tours".localized, "tours")
            ]),
            ("education".localized, [
                ("books".localized, "books"),
                ("courses".localized, "courses"),
                ("online".localized, "online"),
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
                ("other".localized, "other")
            ])
        ]
        
        for (categoryName, subcategories) in subcategoryData {
            guard let category = findCategory(categoryName, .expense) else {
                print("Warning: Category '\(categoryName)' not found for expense subcategories")
                continue
            }
            
            for (index, (subcategoryName, iconName)) in subcategories.enumerated() {
                let subcategory = Subcategory(
                    name: subcategoryName,
                    iconName: iconName,
                    category: category,
                    sortOrder: index,
                    isDefault: true
                )
                context.insert(subcategory)
            }
        }
    }
    
    private static func createIncomeSubcategories(findCategory: (String, CategoryType) -> Category?, context: ModelContext) {
        let subcategoryData: [(categoryName: String, subcategories: [(String, String)])] = [
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
        
        for (categoryName, subcategories) in subcategoryData {
            guard let category = findCategory(categoryName, .income) else {
                print("Warning: Category '\(categoryName)' not found for income subcategories")
                continue
            }
            
            for (index, (subcategoryName, iconName)) in subcategories.enumerated() {
                let subcategory = Subcategory(
                    name: subcategoryName,
                    iconName: iconName,
                    category: category,
                    sortOrder: index,
                    isDefault: true
                )
                context.insert(subcategory)
            }
        }
    }
}
