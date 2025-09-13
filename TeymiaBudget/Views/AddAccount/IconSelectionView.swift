import SwiftUI

struct IconSelectionRow: View {
    let selectedIcon: String
    let selectedColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(selectedIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.primary)
                
                Text("Icon")
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image("chevron.right")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct IconSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    
    private let availableIcons = [
        "cash", "bank", "credit.card", "piggy.bank",
        "wallet", "money.wings", "coins", "crypto.coins",
        "nft", "hand.usd", "hand.bill", "hand.revenue",
        "coins.up", "coins.tax", "shopping.basket", "",
        "briefcase", "cash.simple", "dollar.plant", "master.card",
        "visa", "stripe", "apple.pay", "amazon.pay",
        "bitcoin", "ethereum", "shopify", "paypal"
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
        }
    }
    
    private func iconButton(icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(selectedIcon == icon ? .white : .primary)
                .padding(14)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? Color.primary.opacity(0.8) : Color.secondary.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

