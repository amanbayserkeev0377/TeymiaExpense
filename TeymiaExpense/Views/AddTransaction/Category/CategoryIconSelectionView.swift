import SwiftUI

struct CategorySection: Identifiable {
    let id = UUID()
    let name: String
    let icons: [String]
}

struct CategoryIconSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedIcon: String
    
    private let categories: [CategorySection] = [
        CategorySection(name: "Food & Drinks", icons: [
            "food.drinks", "delivery", "groceries", "restaurant",
            "coffee", "fast.food", "lunches", "apple", "bananas", "chopsticks.noodles", "bowl.rice", "carrot", "croissant", "fish", "grocery.basket", "hamburger", "pizza", "alcohol", "champagne", "cocktail"
        ]),
        
        CategorySection(name: "Transport", icons: [
            "transport", "taxi", "public.transport", "fuel",
            "parking", "repair", "washing"
        ]),
        
        CategorySection(name: "Entertainment", icons: [
            "entertainment", "cinema", "events", "subscriptions",
            "hobbies", "gaming", "vacation"
        ]),
        
        CategorySection(name: "Sports", icons: [
            "sports", "gym", "swimming", "yoga", "equipment"
        ]),
        
        CategorySection(name: "Shopping", icons: [
            "shopping", "clothing", "cosmetics", "electronics",
            "gifts", "marketplaces", "shopping.basket"
        ]),
        
        CategorySection(name: "Health", icons: [
            "health", "dental", "hospital", "pharmacy",
            "checkups", "therapy", "veterinary", "eye", "eye.crossed"
        ]),
        
        CategorySection(name: "Housing", icons: [
            "housing", "rent", "furniture", "home.maintenance",
            "internet", "telephone", "water", "electricity",
            "gas", "tv.cable", "home.fill"
        ]),
        
        CategorySection(name: "Family", icons: [
            "child", "kids.clothes", "school.supplies", "kids.food",
            "kids.healthcare", "toys.entertainment", "gifts.parties",
            "pet", "pet.food", "toys.accessories"
        ]),
        
        CategorySection(name: "Travel", icons: [
            "travel", "flights", "visadocument", "hotel", "tours"
        ]),
        
        CategorySection(name: "Education", icons: [
            "education", "books", "courses", "student.loan", "materials"
        ]),
        
        CategorySection(name: "Finance", icons: [
            "salary", "monthly.salary", "overtime", "bonus",
            "gift", "birthday.gift", "event.gift", "bonuses",
            "performance.bonus", "yearend.bonus", "business",
            "freelance", "consulting", "business.revenue",
            "investment", "dividends", "interest", "crypto",
            "rental.income", "refund", "cashback", "income",
            "bank", "credit.card", "wallet", "piggy.bank",
            "dollar", "expense", "dollar.sack", "dollar.transfer", "coins",
            "coins.up", "coins.tax", "commission", "hand.bill",
            "hand.revenue", "hand.usd", "chart.pie",
            "cash", "cash.simple", "bitcoin", "bitcoin.lock",
            "bitcoin.symbol", "crypto.coins", "nft", "amazon.pay",
            "apple.pay", "paypal", "visa", "master.card", "stripe",
            "shopify", "briefcase", "scales"
        ]),
        
        CategorySection(name: "Miscellaneous", icons: [
            "other", "general", "transfer",
            "pencil",
            "trash"
        ])
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    ForEach(categories) { category in
                        categorySection(category)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationTitle("Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func categorySection(_ category: CategorySection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(category.icons, id: \.self) { icon in
                    iconButton(icon: icon)
                } 
            }
        }
    }
    
    private func iconButton(icon: String) -> some View {
        Button {
            selectedIcon = icon
            dismiss()
        } label: {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(
                    selectedIcon == icon
                    ? (colorScheme == .light ? Color.white : Color.black)
                    : Color.primary
                )
                .padding(10)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color.primary : Color.secondary.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}
