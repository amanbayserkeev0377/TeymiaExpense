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
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    private let categories: [CategorySection] = [
        CategorySection(name: "Food & Drinks", icons: ["fork.knife", "delivery", "groceries", "restaurant", "coffee", "fast.food", "lunches", "apple", "bananas", "chopsticks.noodles", "bowl.rice", "carrot", "croissant", "fish", "grocery.basket", "hamburger", "pizza", "alcohol", "champagne", "cocktail"]),
        CategorySection(name: "Transport", icons: ["transport", "taxi", "public.transport", "car.bus", "bike", "motorcycle", "subway", "train", "fuel", "parking", "repair", "washing"]),
        CategorySection(name: "Entertainment", icons: ["entertainment", "cinema", "events", "subscriptions", "hobbies", "gaming", "chess.piece", "clapper.open", "film", "game.board", "guitar", "music", "piano", "play.alt", "cards", "puzzle"]),
        CategorySection(name: "Sports", icons: ["sports", "basketball", "football", "tennis", "rugby", "golf", "ping.pong", "chess.knight", "gym", "swimming", "yoga", "skiing", "equipment", "sport.uniform", "archery", "laurel.first", "medal", "trophy"]),
        CategorySection(name: "Shopping", icons: ["shopping", "cart.shopping", "clothing", "cosmetics", "electronics", "gifts", "marketplaces", "shopping.basket", "shopping.bag", "tags"]),
        CategorySection(name: "Health", icons: ["health", "dental", "hospital", "pharmacy", "checkups", "therapy", "veterinary", "eye", "heart.brain", "heart.rate", "lungs", "medicine", "health.plus", "smoking", "stethoscope", "syringe", "doctor"]),
        CategorySection(name: "Housing", icons: ["housing", "rent", "furniture", "home.maintenance", "internet", "telephone", "water", "electricity", "gas", "tv.cable", "bath", "bed.empty", "bolt", "lamp.desk", "paint.roller", "toilet.paper", "wrench"]),
        CategorySection(name: "Family", icons: ["family", "family2", "child", "baby", "baby.carriage", "kids.clothes", "school.supplies", "toys.entertainment", "gifts.parties", "pet", "pet.food", "pets", "paw", "cat", "toys.accessories", "birthday.gift", "gift"]),
        CategorySection(name: "Travel", icons: ["travel", "flights", "visadocument", "hotel", "tours", "vacation", "chinese", "compass", "map.marker", "luggage", "plane.globe", "world"]),
        CategorySection(name: "Education", icons: ["education", "books", "courses", "book.bookmark", "books2", "student", "writer", "scientist", "glasses", "calculator", "square.root", "square.poll", "physics", "react", "ai.technology", "ai.assistant", "language.exchange", "language", "pen.swirl", "pen.paintbrush"]),
        CategorySection(name: "Finance", icons: ["salary", "monthly.salary", "overtime", "bonus", "business", "freelance", "consulting", "business.revenue", "investment", "dividends", "refund", "cashback", "income", "bank", "credit.card", "wallet", "piggy.bank", "dollar", "expense", "dollar.sack", "dollar.transfer", "coins", "commission", "hand.bill", "hand.revenue", "hand.usd", "chart.pie", "cash", "cash.simple", "bitcoin.lock", "bitcoin.symbol", "crypto.coins", "nft", "briefcase", "transfer"]),
        CategorySection(name: "Brands", icons: ["visa", "stripe", "paypal", "apple.pay", "amazon.pay", "master.card", "bitcoin", "ethereum", "shopify", "instagram", "whatsapp", "threads", "twitter", "meta", "tik.tok", "telegram", "vk", "youtube", "spotify", "reddit", "github", "appstore", "apple.company", "android", "discord", "starbucks", "nvidia", "soundcloud", "twitch", "huawei", "burger.king", "t.mobile", "airbnb", "mcdonalds", "ebay", "fedex", "flaticon", "netflix", "sony", "uber"]),
        CategorySection(name: "Miscellaneous", icons: ["other", "general", "pencil", "trash", "materials", "sun", "moon", "alien", "candle", "diamond", "paperclip", "poop", "shoe.prints", "snooze", "sparkles", "bell", "bookmark", "clock", "comment", "cursor", "dice", "envelope", "flame", "folder", "footprint", "headset", "heart", "info", "keyboard", "lock", "paperplane", "phone.flip", "rocket", "scissors", "search", "smile", "like", "trees", "umbrella", "wheat", "calendar"])
    ]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    // MARK: - Filter

    private var filteredSections: [CategorySection] {
        if searchText.isEmpty {
            return categories
        }
        
        let lowercasedSearch = searchText.lowercased()
        
        return categories.compactMap { category in
            let filteredIcons = category.icons.filter { icon in
                if icon.lowercased().contains(lowercasedSearch) { return true }
                if let keywords = ruKeywords[icon], keywords.contains(where: { $0.contains(lowercasedSearch) }) {
                    return true
                }
                return false
            }
            
            let nameMatches = category.name.lowercased().contains(lowercasedSearch)
            if nameMatches || !filteredIcons.isEmpty {
                return CategorySection(
                    name: category.name,
                    icons: nameMatches ? category.icons : filteredIcons
                )
            } else {
                return nil
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if filteredSections.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .padding(.top, 100)
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(filteredSections) { category in
                            categorySection(category)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("icon".localized)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .automatic)
            .focused($isSearchFocused)
            .autocorrectionDisabled()
            .toolbar {
                CloseToolbarButton()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func categorySection(_ category: CategorySection) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category.name)
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(.primary)
                .padding(.horizontal, 6)
            
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
                        .fill(selectedIcon == icon ? Color.primary : Color.secondary.opacity(0.07))
                )
        }
        .buttonStyle(.plain)
    }
}
