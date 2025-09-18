import SwiftUI

struct CategoryIconSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedIcon: String
    
    private let availableIcons = [
        // Food & Drinks
        "food.drinks", "delivery", "groceries", "restaurant", "coffee", "fast.food", "alcohol", "lunches",
        
        // Transport
        "transport", "taxi", "public.transport", "fuel", "parking", "repair", "washing",
        
        // Entertainment
        "entertainment", "cinema", "events", "subscriptions", "hobbies", "gaming", "vacation",
        
        // Sports
        "sports", "equipment", "gym", "swimming", "yoga",
        
        // Shopping
        "shopping", "clothing", "cosmetics", "electronics", "gifts", "marketplaces",
        
        // Health
        "health", "dental", "hospital", "pharmacy", "checkups", "therapy",
        
        // Housing
        "housing", "rent", "furniture", "home.maintenance", "internet", "telephone",
        "water", "electricity", "gas", "tv.cable",
        
        // Travel
        "travel", "flights", "visadocument", "hotel", "tours",
        
        // Education
        "education", "books", "courses", "student.loan", "materials",
        
        // Pet
        "pet", "pet.food", "veterinary", "toys.accessories",
        
        // Child
        "child", "kids.clothes", "school.supplies", "kids.food", "kids.healthcare",
        "toys.entertainment", "gifts.parties",
        
        // Income
        "salary", "monthly.salary", "overtime", "bonus", "gift", "birthday.gift", "event.gift",
        "bonuses", "performance.bonus", "yearend.bonus", "commission", "business", "freelance",
        "consulting", "business.revenue", "investment", "dividends", "interest", "crypto",
        "rental.income", "refund", "cashback",
        
        // Other
        "other", "general"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 4)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(availableIcons, id: \.self) { icon in
                        iconButton(icon: icon)
                    }
                }
                .padding(20)
                .padding(.top, 20)
            }
            .navigationTitle("Category Icon")
            .navigationBarTitleDisplayMode(.inline)
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
                .frame(width: 32, height: 32)
                .foregroundStyle(
                    selectedIcon == icon
                    ? (colorScheme == .light ? Color.white : Color.black)
                    : Color.primary
                )
                .padding(14)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color.primary.opacity(0.9) : Color.secondary.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}
